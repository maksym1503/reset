import XCTest

final class ResetUITests: XCTestCase {
    @MainActor func testWorldGestureHistoryAndAppearance() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-skip-onboarding"]
        app.launch()
        XCTAssertTrue(app.tabBars.buttons["Settings"].waitForExistence(timeout: 15))
        app.tabBars.buttons["Settings"].tap()
        app.buttons["Reset progress"].tap()
        app.buttons["Delete"].tap()
        app.tabBars.buttons["Today"].tap()
        let ritual = app.buttons["ritual-object"]
        XCTAssertTrue(ritual.waitForExistence(timeout: 5))
        capture("light-today-before")
        // A short cancelled pull must not leave a partial state or log completion.
        let start = ritual.coordinate(withNormalizedOffset: CGVector(dx: 0.12, dy: 0.5))
        start.press(forDuration: 0.05, thenDragTo: ritual.coordinate(withNormalizedOffset: CGVector(dx: 0.22,dy: 0.5)))
        XCTAssertFalse(app.staticTexts["Clear desk. Fresh perspective."].exists)
        capture("cancelled-gesture")
        app.buttons["mochi"].tap()
        capture("mochi-reaction")
        start.press(forDuration: 0.05, thenDragTo: ritual.coordinate(withNormalizedOffset: CGVector(dx: 0.94,dy: 0.5)))
        XCTAssertTrue(app.staticTexts["Clear desk. Fresh perspective."].waitForExistence(timeout: 5))
        capture("light-today-after")
        app.tabBars.buttons["Progress"].tap()
        XCTAssertTrue(app.buttons["history-expand"].waitForExistence(timeout: 5))
        capture("light-progress")
        app.buttons["history-expand"].tap()
        XCTAssertTrue(app.buttons["history-expand"].label == "Show week")
        capture("expanded-history")
        app.buttons["history-expand"].tap()
        XCTAssertEqual(app.buttons["history-expand"].label, "See more")
        let formatter = DateFormatter(); formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        let yesterday = Calendar(identifier: .gregorian).date(byAdding: .day, value: -1, to: Date())!
        app.buttons[formatter.string(from: yesterday)].tap()
        XCTAssertTrue(app.buttons["history-edit"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons["history-edit"].label, "Add completion")
        capture("history-add")
        app.buttons["history-edit"].tap()
        app.buttons["history-edit"].tap()
        XCTAssertTrue(app.buttons["history-edit"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons["history-edit"].label, "Remove completion")
        capture("history-remove")
        let editPosition = app.buttons["history-edit"].frame.minY
        app.buttons["history-edit"].tap()
        XCTAssertTrue(app.staticTexts["Remove this completion?"].exists)
        XCTAssertEqual(app.buttons["history-edit"].frame.minY, editPosition, accuracy: 2)
        capture("history-remove-confirmation")
        app.buttons["Cancel"].tap()
        XCTAssertEqual(app.buttons["history-edit"].label, "Remove completion")
        app.buttons["history-edit"].tap()
        app.buttons["history-edit"].tap()
        XCTAssertEqual(app.buttons["history-edit"].label, "Add completion")
        XCTAssertEqual(app.buttons["history-edit"].frame.minY, editPosition, accuracy: 2)
        capture("history-removed")
        app.buttons["Done"].tap()
        let tomorrow = Calendar(identifier: .gregorian).date(byAdding: .day, value: 1, to: Date())!
        app.buttons[formatter.string(from: tomorrow)].tap()
        XCTAssertFalse(app.buttons["history-edit"].exists)
        capture("future-protected")
        app.buttons["Done"].tap()
        app.swipeUp()
        capture("progress-rewards")
        app.buttons["milestone-0"].tap()
        capture("milestone-detail")
        app.buttons["Lovely"].tap()
        app.tabBars.buttons["Today"].tap()
        app.buttons["Undo today’s reset"].tap()
        XCTAssertFalse(app.staticTexts["Clear desk. Fresh perspective."].exists)
    }

    @MainActor func testDarkWorldAndMidGesture() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-skip-onboarding", "-qa-dark", "-qa-drag"]
        app.launch()
        XCTAssertTrue(app.buttons["ritual-object"].waitForExistence(timeout: 15))
        capture("dark-gesture-midpoint-fixture")
        app.tabBars.buttons["Progress"].tap()
        capture("dark-progress")
        app.tabBars.buttons["Settings"].tap()
        capture("dark-settings")
    }

    @MainActor func testVisualCoverage() throws {
        let app = XCUIApplication()
        for appearance in ["Light", "Dark"] {
            app.launchArguments = ["-skip-onboarding", "-qa-" + appearance.lowercased()]
            app.launch()
            XCTAssertTrue(app.buttons["ritual-object"].waitForExistence(timeout: 15))
            if app.buttons["Undo today’s reset"].exists { app.buttons["Undo today’s reset"].tap() }
            capture("\(appearance)-before")
            let object = app.buttons["ritual-object"]
            object.coordinate(withNormalizedOffset: CGVector(dx: 0.12,dy: 0.5)).press(forDuration: 0.05,
                thenDragTo: object.coordinate(withNormalizedOffset: CGVector(dx: 0.94,dy: 0.5)))
            capture("\(appearance)-after")
            app.tabBars.buttons["Progress"].tap()
            capture("\(appearance)-progress-overview")
            app.buttons["history-expand"].tap()
            capture("\(appearance)-expanded")
            app.buttons["history-today"].tap()
            XCTAssertFalse(app.buttons["history-edit"].exists)
            capture("\(appearance)-today-detail")
            app.buttons["Done"].tap()
            app.tabBars.buttons["Today"].tap()
            app.buttons["Undo today’s reset"].tap()
            app.terminate()
        }
        app.launchArguments = ["-resetOnboarding"]
        app.launch()
        capture("onboarding")
        app.terminate()
        app.launchArguments = ["-skip-onboarding", "-qa-large-text"]
        app.launch()
        XCTAssertTrue(app.buttons["ritual-object"].waitForExistence(timeout: 15))
        capture("accessibility-today")
        app.swipeUp()
        app.swipeUp()
        capture("accessibility-instruction")
        app.tabBars.buttons["Progress"].tap()
        capture("accessibility-progress")
    }

    @MainActor func testLargeTextCanScrollThroughScene() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-skip-onboarding", "-qa-large-text"]
        app.launch()
        XCTAssertTrue(app.buttons["ritual-object"].waitForExistence(timeout: 15))
        let surface = app.buttons["ritual-object"]
        // Start inside the habit object: vertical intent must remain page scrolling.
        let start = surface.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        start.press(forDuration: 0.05, thenDragTo: start.withOffset(CGVector(dx: 0,dy: -260)))
        app.scrollViews.firstMatch.swipeUp()
        XCTAssertTrue(app.staticTexts["Mochi will take care of the finishing touches."].isHittable)
        capture("accessibility-scrolled-instruction")
    }

    @MainActor private func capture(_ name: String) {
        Thread.sleep(forTimeInterval: 0.6)
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
}
