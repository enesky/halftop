import Foundation
import AppKit

let logDir = URL(fileURLWithPath: NSHomeDirectory())
    .appendingPathComponent("Library/Logs/StartSideScreen", isDirectory: true)
let logFile = logDir.appendingPathComponent("start-sidescreen-usb.log")

func appendLog(_ message: String) {
    try? FileManager.default.createDirectory(at: logDir, withIntermediateDirectories: true)
    let line = "\(Date()) \(message)\n"
    if let data = line.data(using: .utf8) {
        if FileManager.default.fileExists(atPath: logFile.path),
           let handle = try? FileHandle(forWritingTo: logFile) {
            try? handle.seekToEnd()
            try? handle.write(contentsOf: data)
            try? handle.close()
        } else {
            try? data.write(to: logFile)
        }
    }
}

func run(_ executable: String, _ arguments: [String]) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executable)
    process.arguments = arguments
    do {
        try process.run()
    } catch {
        appendLog("failed to run \(executable): \(error)")
    }
}

appendLog("launch")
run("/usr/bin/afplay", ["-t", "0.07", "/System/Library/Sounds/Funk.aiff"])

let appURL = URL(fileURLWithPath: "/Applications/SideScreen.app")
let autoStartURL = URL(string: "sidescreen://auto-start-usb")!

if NSWorkspace.shared.open(autoStartURL) {
    appendLog("opened sidescreen://auto-start-usb")
} else {
    let configuration = NSWorkspace.OpenConfiguration()
    configuration.arguments = ["--auto-start-usb"]
    NSWorkspace.shared.openApplication(at: appURL, configuration: configuration) { _, error in
        if let error {
            appendLog("failed to open SideScreen with --auto-start-usb: \(error)")
            run("/usr/bin/afplay", ["-t", "0.2", "/System/Library/Sounds/Sosumi.aiff"])
        } else {
            appendLog("opened SideScreen with --auto-start-usb fallback")
        }
        CFRunLoopStop(CFRunLoopGetMain())
    }
    CFRunLoopRun()
}

if !FileManager.default.fileExists(atPath: appURL.path) {
    appendLog("missing app: \(appURL.path)")
    run("/usr/bin/afplay", ["-t", "0.2", "/System/Library/Sounds/Sosumi.aiff"])
}
