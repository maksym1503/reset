import Foundation
import SwiftData

public struct ResetClock: Sendable {
    public var now: @Sendable () -> Date
    public init(now: @escaping @Sendable () -> Date = Date.init) { self.now = now }
}

@Model public final class ResetRecord {
    @Attribute(.unique) public var localDate: String
    public var completedAt: Date
    public init(localDate: String, completedAt: Date) { self.localDate = localDate; self.completedAt = completedAt }
}

public struct ResetProgress: Equatable, Sendable {
    public let total: Int
    public let streak: Int
    public let bestStreak: Int
    public let level: Int
    public let history: [String]
    public init(total: Int, streak: Int, bestStreak: Int, level: Int, history: [String]) {
        self.total = total; self.streak = streak; self.bestStreak = bestStreak; self.level = level; self.history = history
    }
}

public enum ResetDay {
    public static func calendar(timeZone: TimeZone = .current) -> Calendar { var c = Calendar(identifier: .gregorian); c.timeZone = timeZone; return c }
    public static func key(_ date: Date, calendar: Calendar = ResetDay.calendar()) -> String { let c = calendar.dateComponents([.year, .month, .day], from: date); return String(format: "%04d-%02d-%02d", c.year!, c.month!, c.day!) }
    public static func date(_ key: String, calendar: Calendar = ResetDay.calendar()) -> Date? { let p = key.split(separator: "-").compactMap { Int($0) }; guard p.count == 3 else { return nil }; return calendar.date(from: DateComponents(year: p[0], month: p[1], day: p[2])) }
}

@MainActor public final class ResetStore {
    private let context: ModelContext
    private let clock: ResetClock
    private let calendar: Calendar
    public init(context: ModelContext, clock: ResetClock = ResetClock(), calendar: Calendar = ResetDay.calendar()) throws { self.context = context; self.clock = clock; self.calendar = ResetDay.calendar(timeZone: calendar.timeZone); context.autosaveEnabled = false; try context.save() }
    @discardableResult public func complete() throws -> Bool { try complete(on: clock.now()) }
    @discardableResult public func complete(on date: Date) throws -> Bool { guard calendar.startOfDay(for: date) <= calendar.startOfDay(for: clock.now()) else { return false }; let key = ResetDay.key(date, calendar: calendar); guard try today(key) == nil else { return false }; context.insert(ResetRecord(localDate: key, completedAt: clock.now())); try context.save(); return true }
    @discardableResult public func setHistoricalCompletion(on date: Date, completed: Bool) throws -> Bool {
        guard calendar.startOfDay(for: date) < calendar.startOfDay(for: clock.now()) else { return false }
        if completed {
            do { return try complete(on: date) } catch { context.rollback(); throw error }
        }
        guard let record = try today(ResetDay.key(date, calendar: calendar)) else { return false }
        context.delete(record)
        do { try context.save() } catch { context.rollback(); throw error }
        return true
    }
    public func undoToday() throws { if let record = try today(ResetDay.key(clock.now(), calendar: calendar)) { context.delete(record); try context.save() } }
    public func reset() throws { try all().forEach(context.delete); try context.save() }
    public func progress() throws -> ResetProgress { let records = try all(); let dates = Set(records.compactMap { ResetDay.date($0.localDate, calendar: calendar) }); let sorted = dates.sorted(); let today = calendar.startOfDay(for: clock.now()); var cursor = dates.contains(today) ? today : calendar.date(byAdding: .day, value: -1, to: today)!; var streak = 0; while dates.contains(cursor) { streak += 1; cursor = calendar.date(byAdding: .day, value: -1, to: cursor)! }; var best = 0; var run = 0; for i in sorted.indices { run = i > 0 && calendar.date(byAdding: .day, value: 1, to: sorted[i - 1]) == sorted[i] ? run + 1 : 1; best = max(best, run) }; return ResetProgress(total: dates.count, streak: streak, bestStreak: best, level: 1 + dates.count / 5, history: records.map(\.localDate)) }
    private func all() throws -> [ResetRecord] { try context.fetch(FetchDescriptor<ResetRecord>(sortBy: [SortDescriptor(\.localDate)])) }
    private func today(_ key: String) throws -> ResetRecord? { var d = FetchDescriptor<ResetRecord>(predicate: #Predicate { $0.localDate == key }); d.fetchLimit = 1; return try context.fetch(d).first }
}
