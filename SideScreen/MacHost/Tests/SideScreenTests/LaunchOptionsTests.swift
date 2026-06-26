import XCTest
@testable import SideScreen

final class LaunchOptionsTests: XCTestCase {
    func testAutoStartUSBRecognizesCanonicalArgument() {
        let options = LaunchOptions(arguments: ["SideScreen", "--auto-start-usb"])
        XCTAssertTrue(options.autoStartUSB)
    }

    func testAutoStartUSBDefaultsToFalse() {
        let options = LaunchOptions(arguments: ["SideScreen"])
        XCTAssertFalse(options.autoStartUSB)
    }

    func testAutoStartUSBRecognizesURLHost() {
        XCTAssertTrue(LaunchOptions.requestsAutoStartUSB(url: URL(string: "sidescreen://auto-start-usb")!))
    }

    func testAutoStartUSBIgnoresOtherURLs() {
        XCTAssertFalse(LaunchOptions.requestsAutoStartUSB(url: URL(string: "sidescreen://settings")!))
    }
}
