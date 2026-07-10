import Foundation

enum SystemSleepError: LocalizedError {
    case commandFailed(String)

    var errorDescription: String? {
        switch self {
        case .commandFailed(let output):
            "Could not put the system to sleep: \(output)"
        }
    }
}

struct SystemSleep {
    static func sleepNow() throws {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        process.arguments = ["sleepnow"]
        process.standardOutput = pipe
        process.standardError = pipe
        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            throw SystemSleepError.commandFailed(output.isEmpty ? "exit code \(process.terminationStatus)" : output)
        }
    }
}
