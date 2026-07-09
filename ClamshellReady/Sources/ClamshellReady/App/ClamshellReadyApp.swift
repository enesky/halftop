import SwiftUI

@main struct ClamshellReadyApp: App {
    @State private var monitor = SystemMonitor()
    var body: some Scene {
        MenuBarExtra("Clamshell Ready", systemImage: monitor.menuBarIcon) { MenuContentView(monitor: monitor) }
            .menuBarExtraStyle(.window)
    }
}
