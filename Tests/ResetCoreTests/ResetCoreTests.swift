import XCTest
import SwiftData
@testable import ResetCore

@MainActor final class ResetCoreTests: XCTestCase {
    private func makeStore(_ date: Date = Date(timeIntervalSince1970: 1_800_000_000)) throws -> ResetStore { let c = try ModelContainer(for: ResetRecord.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)); return try ResetStore(context: ModelContext(c), clock: ResetClock(now: { date }), calendar: ResetDay.calendar(timeZone: TimeZone(secondsFromGMT: 0)!)) }
    func testCompletionIsUniqueAndAwardsProgress() throws { let s = try makeStore(); XCTAssertTrue(try s.complete()); XCTAssertFalse(try s.complete()); XCTAssertEqual(try s.progress().total, 1); XCTAssertEqual(try s.progress().streak, 1) }
    func testUndoAndReset() throws { let s = try makeStore(); try s.complete(); try s.undoToday(); XCTAssertEqual(try s.progress().total, 0); try s.complete(); try s.reset(); XCTAssertEqual(try s.progress().total, 0) }
    func testStreakAndLevel() throws { let d = Date(timeIntervalSince1970: 1_800_000_000); let c = try ModelContainer(for: ResetRecord.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)); var cal = ResetDay.calendar(timeZone: TimeZone(secondsFromGMT: 0)!); let ctx = ModelContext(c); for i in 0..<5 { let day = cal.date(byAdding: .day, value: -i, to: d)!; ctx.insert(ResetRecord(localDate: ResetDay.key(day, calendar: cal), completedAt: day)) }; try ctx.save(); let s = try ResetStore(context: ModelContext(c), clock: ResetClock(now: { d }), calendar: cal); XCTAssertEqual(try s.progress().streak, 5); XCTAssertEqual(try s.progress().level, 2) }
}
