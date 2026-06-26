import Foundation

struct LaunchOptions {
    let autoStartUSB: Bool

    init(arguments: [String]) {
        let normalized = Set(arguments.dropFirst())
        self.autoStartUSB = normalized.contains("--auto-start-usb") ||
            normalized.contains("--auto-start") ||
            normalized.contains("--autostart-usb")
    }

    static func requestsAutoStartUSB(url: URL) -> Bool {
        guard url.scheme?.lowercased() == "sidescreen" else { return false }
        let host = url.host?.lowercased()
        let path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")).lowercased()
        return host == "auto-start-usb" || path == "auto-start-usb"
    }
}
