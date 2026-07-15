import AppKit
import SwiftUI

@main
struct HalftopApp: App {
    @StateObject private var monitor: SystemMonitor
    @StateObject private var tools: ToolController
    @StateObject private var shortcuts: GlobalShortcutStore

    init() {
        let monitor = SystemMonitor()
        let tools = ToolController()
        let shortcuts = GlobalShortcutStore()
        shortcuts.configure(tools: tools, monitor: monitor)
        _monitor = StateObject(wrappedValue: monitor)
        _tools = StateObject(wrappedValue: tools)
        _shortcuts = StateObject(wrappedValue: shortcuts)
    }

    var body: some Scene {
        MenuBarExtra {
            MenuContentView(monitor: monitor, tools: tools, shortcuts: shortcuts)
                .onAppear {
                    tools.refreshServices()
                    shortcuts.configure(tools: tools, monitor: monitor)
                }
                .onOpenURL { tools.run(url: $0) }
                .onChange(of: tools.sideScreen.availabilityKey) { _, _ in
                    shortcuts.configure(tools: tools, monitor: monitor)
                }
        } label: {
            Image(nsImage: MenuBarIcon.image)
                .accessibilityLabel("Halftop")
        }
        .menuBarExtraStyle(.window)
    }
}
