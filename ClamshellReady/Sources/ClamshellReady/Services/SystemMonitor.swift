import AppKit
import CoreGraphics
import IOKit
import IOKit.ps
import Observation
import ServiceManagement

@MainActor @Observable final class SystemMonitor {
    private(set) var hasExternalDisplay = false
    private(set) var isOnACPower = false
    private(set) var lidState: LidState = .unavailable
    private(set) var assertionActive = false
    private(set) var lidOverrideActive = false
    private(set) var errorMessage: String?
    private(set) var launchAtLogin = SMAppService.mainApp.status == .enabled
    private(set) var allowOnBattery = UserDefaults.standard.bool(forKey: "allowOnBattery")
    private(set) var activeModeEnabled = UserDefaults.standard.object(forKey: "activeModeEnabled") as? Bool ?? true
    private let assertion = PowerAssertion()
    private var timer: Timer?
    private var observers: [NSObjectProtocol] = []
    private var ownsLidOverride = false
    private var lastActionError: String?

    var mode: ActiveMode { .resolve(hasExternalDisplay: hasExternalDisplay, isOnACPower: isOnACPower, allowOnBattery: allowOnBattery, activeModeEnabled: activeModeEnabled) }
    var menuBarIcon: String { mode == .clamshellReady ? "display.and.arrow.down" : "display" }

    init() {
        ActiveMode.selfCheck()
        refresh()
        let center = NSWorkspace.shared.notificationCenter
        for name in [NSWorkspace.screensDidSleepNotification, NSWorkspace.screensDidWakeNotification] {
            observers.append(center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in Task { @MainActor in self?.refresh() } })
        }
        timer = .scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in Task { @MainActor in self?.refresh() } }
    }

    func refresh() {
        hasExternalDisplay = Self.detectExternalDisplay()
        isOnACPower = Self.detectACPower()
        lidState = Self.detectLidState()
        do {
            try assertion.update(shouldBeActive: activeModeEnabled && hasExternalDisplay && (isOnACPower || allowOnBattery))
            assertionActive = assertion.isActive
            lidOverrideActive = (try? LidSleepOverride.isEnabled()) ?? lidOverrideActive
            errorMessage = lastActionError
        } catch { assertionActive = false; errorMessage = error.localizedDescription }
        launchAtLogin = SMAppService.mainApp.status == .enabled
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
            launchAtLogin = enabled
            errorMessage = nil
        } catch {
            launchAtLogin = SMAppService.mainApp.status == .enabled
            errorMessage = "Could not update Launch at Login: \(error.localizedDescription)"
        }
    }
    func setAllowOnBattery(_ enabled: Bool) {
        allowOnBattery = enabled
        UserDefaults.standard.set(enabled, forKey: "allowOnBattery")
        refresh()
    }
    func setActiveModeEnabled(_ enabled: Bool) {
        activeModeEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "activeModeEnabled")
        if !enabled { restoreNormalPowerBehavior() }
        refresh()
    }
    func setLidOverrideEnabled(_ enabled: Bool) {
        do {
            try LidSleepOverride.setEnabled(enabled)
            ownsLidOverride = enabled
            lidOverrideActive = enabled
            lastActionError = nil
            refresh()
        } catch {
            lastActionError = error.localizedDescription
            refresh()
        }
    }
    func stop() {
        restoreNormalPowerBehavior()
    }
    func goToSleep() {
        restoreNormalPowerBehavior()
        do {
            try SystemSleep.sleepNow()
            lastActionError = nil
        } catch {
            lastActionError = error.localizedDescription
            refresh()
        }
    }

    private func restoreNormalPowerBehavior() {
        assertion.release()
        assertionActive = false
        if lidOverrideActive || ownsLidOverride {
            do {
                try LidSleepOverride.setEnabled(false)
                lidOverrideActive = false
                ownsLidOverride = false
                lastActionError = nil
            } catch {
                lastActionError = error.localizedDescription
            }
        }
    }

    private static func detectExternalDisplay() -> Bool {
        var count: UInt32 = 0
        guard CGGetOnlineDisplayList(0, nil, &count) == .success else { return false }
        var displays = [CGDirectDisplayID](repeating: 0, count: Int(count))
        guard CGGetOnlineDisplayList(count, &displays, &count) == .success else { return false }
        return displays.prefix(Int(count)).contains {
            CGDisplayIsBuiltin($0) == 0 && CGDisplayVendorNumber($0) != 0 && CGDisplayModelNumber($0) != 0
        }
    }
    private static func detectACPower() -> Bool {
        IOPSCopyExternalPowerAdapterDetails()?.takeRetainedValue() != nil
    }
    private static func detectLidState() -> LidState {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPMrootDomain"))
        guard service != 0 else { return .unavailable }
        defer { IOObjectRelease(service) }
        guard let value = IORegistryEntryCreateCFProperty(service, "AppleClamshellState" as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue() as? Bool else { return .unavailable }
        return value ? .closed : .open
    }
}
