import Foundation

enum LidSleepOverrideError: LocalizedError {
    case commandFailed(String)

    var errorDescription: String? {
        switch self {
        case .commandFailed(let output):
            "Could not update lid behavior: \(output)"
        }
    }
}

struct LidSleepOverride {
    static func isEnabled() throws -> Bool {
        let output = try run("/usr/bin/pmset", ["-g"])
        if let sleepDisabled = output
            .split(separator: "\n")
            .first(where: { $0.contains("SleepDisabled") })?
            .lastWhitespaceSeparatedField {
            return sleepDisabled == "1"
        }

        let customOutput = try run("/usr/bin/pmset", ["-g", "custom"])
        return customOutput
            .split(separator: "\n")
            .first { $0.contains("disablesleep") }?
            .lastWhitespaceSeparatedField == "1"
    }

    static func setEnabled(_ enabled: Bool) throws {
        let value = enabled ? "1" : "0"
        try run("/usr/bin/osascript", [
            "-e",
            #"do shell script "/usr/bin/pmset -b disablesleep \#(value)" with administrator privileges"#
        ])
    }

    @discardableResult
    private static func run(_ executable: String, _ arguments: [String]) throws -> String {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.standardOutput = pipe
        process.standardError = pipe
        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard process.terminationStatus == 0 else {
            throw LidSleepOverrideError.commandFailed(output.isEmpty ? "exit code \(process.terminationStatus)" : output)
        }

        return output
    }
}

private extension Substring {
    var lastWhitespaceSeparatedField: Substring? {
        split(whereSeparator: { $0.isWhitespace }).last
    }
}
