import XCTest

final class ResetUITests: XCTestCase {
    @MainActor func testResetActionIsVisible() throws {
        let app = XCUIApplication(); app.launchArguments = ["-skip-onboarding"]; app.launch()
        XCTAssertTrue(app.buttons["Reset desk"].waitForExistence(timeout: 10))
    }
}
