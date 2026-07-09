// swift-tools-version: 6.0
import PackageDescription
let package = Package(name: "ClamshellReady", platforms: [.macOS(.v14)], products: [.executable(name: "ClamshellReady", targets: ["ClamshellReady"])], targets: [.executableTarget(name: "ClamshellReady")])
