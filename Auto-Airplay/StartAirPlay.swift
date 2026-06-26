import Foundation

let scriptPath = "/Users/eky/Documents/MacOS Apps/Auto-Airplay/run-airplay.sh"
let logDir = "/Users/eky/Library/Logs/StartAirPlay"
let logPath = "\(logDir)/start-airplay.log"

try? FileManager.default.createDirectory(atPath: logDir, withIntermediateDirectories: true)

func appendLog(_ line: String) {
    let text = line + "\n"
    if let data = text.data(using: .utf8) {
        if FileManager.default.fileExists(atPath: logPath),
           let handle = try? FileHandle(forWritingTo: URL(fileURLWithPath: logPath)) {
            try? handle.seekToEnd()
            try? handle.write(contentsOf: data)
            try? handle.close()
        } else {
            try? data.write(to: URL(fileURLWithPath: logPath))
        }
    }
}

let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
appendLog("")
appendLog("[\(dateFormatter.string(from: Date()))] StartAirPlay.app launched")

guard FileManager.default.isExecutableFile(atPath: scriptPath) else {
    appendLog("ERROR: Script not found or not executable: \(scriptPath)")
    let errorSound = Process()
    errorSound.executableURL = URL(fileURLWithPath: "/usr/bin/afplay")
    errorSound.arguments = ["-t", "0.2", "/System/Library/Sounds/Basso.aiff"]
    try? errorSound.run()
    exit(1)
}

let process = Process()
process.executableURL = URL(fileURLWithPath: "/bin/bash")
process.arguments = [scriptPath]
process.environment = [
    "PATH": "/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin",
    "HOME": "/Users/eky",
    "USER": "eky"
]

let logURL = URL(fileURLWithPath: logPath)
let logHandle = try? FileHandle(forWritingTo: logURL)
try? logHandle?.seekToEnd()
if let logHandle {
    process.standardOutput = logHandle
    process.standardError = logHandle
}

do {
    try process.run()
    process.waitUntilExit()
    appendLog("[\(dateFormatter.string(from: Date()))] exit code: \(process.terminationStatus)")
    exit(process.terminationStatus)
} catch {
    appendLog("ERROR: \(error.localizedDescription)")
    exit(1)
}
