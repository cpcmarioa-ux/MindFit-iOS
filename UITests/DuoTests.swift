import XCTest

final class DuoTests: XCTestCase {
    func testDemoSurvivesRotation() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["--demo"]
        XCUIDevice.shared.orientation = .portrait
        app.launch()
        let name = app.webViews.textFields.firstMatch
        XCTAssertTrue(name.waitForExistence(timeout: 90), "El cuestionario debe cargar desde el servidor")
        name.tap()
        name.typeText("Duo")
        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertEqual(name.value as? String, "Duo")
        XCUIDevice.shared.orientation = .portrait
        XCTAssertEqual(name.value as? String, "Duo")
    }
}
