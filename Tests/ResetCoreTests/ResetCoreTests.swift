import XCTest
import SwiftData
@testable import ResetCore

@MainActor final class ResetCoreTests: XCTestCase {
    private func makeStore(_ date: Date = Date(timeIntervalSince1970: 1_800_000_000)) throws -> ResetStore { let c = try ModelContainer(for: ResetRecord.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)); return try ResetStore(context: ModelContext(c), clock: ResetClock(now: { date }), calendar: ResetDay.calendar(timeZone: TimeZone(secondsFromGMT: 0)!)) }
    func testCompletionIsUniqueAndAwardsProgress() throws { let s = try makeStore(); XCTAssertTrue(try s.complete()); XCTAssertFalse(try s.complete()); XCTAssertEqual(try s.progress().total, 1); XCTAssertEqual(try s.progress().streak, 1) }
    func testUndoAndReset() throws { let s = try makeStore(); try s.complete(); try s.undoToday(); XCTAssertEqual(try s.progress().total, 0); try s.complete(); try s.reset(); XCTAssertEqual(try s.progress().total, 0) }
    func testStreakAndLevel() throws { let d = Date(timeIntervalSince1970: 1_800_000_000); let c = try ModelContainer(for: ResetRecord.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)); var cal = ResetDay.calendar(timeZone: TimeZone(secondsFromGMT: 0)!); let ctx = ModelContext(c); for i in 0..<5 { let day = cal.date(byAdding: .day, value: -i, to: d)!; ctx.insert(ResetRecord(localDate: ResetDay.key(day, calendar: cal), completedAt: day)) }; try ctx.save(); let s = try ResetStore(context: ModelContext(c), clock: ResetClock(now: { d }), calendar: cal); XCTAssertEqual(try s.progress().streak, 5); XCTAssertEqual(try s.progress().level, 2) }

    func testHistoricalEditIsReversibleAndRecalculatesProgress() throws {
        let s = try makeStore()
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        for offset in 1...5 {
            let day = calendar.date(byAdding: .day, value: -offset, to: now)!
            XCTAssertTrue(try s.setHistoricalCompletion(on: day, completed: true))
            XCTAssertFalse(try s.setHistoricalCompletion(on: day, completed: true))
        }
        XCTAssertEqual(try s.progress().total, 5)
        XCTAssertEqual(try s.progress().streak, 5)
        XCTAssertEqual(try s.progress().level, 2)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        XCTAssertTrue(try s.setHistoricalCompletion(on: yesterday, completed: false))
        XCTAssertFalse(try s.setHistoricalCompletion(on: yesterday, completed: false))
        XCTAssertEqual(try s.progress().total, 4)
        XCTAssertEqual(try s.progress().streak, 0)
        XCTAssertEqual(try s.progress().level, 1)
        XCTAssertTrue(try s.setHistoricalCompletion(on: yesterday, completed: true))
        XCTAssertEqual(try s.progress().streak, 5)
    }

    func testHistoryCannotEditTodayOrFuture() throws {
        let s = try makeStore()
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        XCTAssertFalse(try s.setHistoricalCompletion(on: now, completed: true))
        XCTAssertFalse(try s.setHistoricalCompletion(on: now.addingTimeInterval(86400), completed: true))
        try s.complete()
        XCTAssertFalse(try s.setHistoricalCompletion(on: now, completed: false))
        XCTAssertEqual(try s.progress().total, 1)
    }
}
