import SwiftUI
import UIKit
import SwiftData
import ResetFoundation
import ResetCore

@main struct ResetApp: App { var body: some Scene { WindowGroup { ResetStartup() } } }

@MainActor @Observable final class ResetSession {
    let store: ResetStore; var progress: ResetProgress; var day = ResetDay.key(Date()); var celebration = 0; var error: String?
    init() throws { let container = try ModelContainer(for: ResetRecord.self); store = try ResetStore(context: ModelContext(container)); progress = try store.progress() }
    var completed: Bool { progress.history.contains(day) }
    func perform(_ action: (ResetStore) throws -> Void = { _ in }) { do { try action(store); progress = try store.progress(); day = ResetDay.key(Date()); celebration += 1 } catch { self.error = "Reset could not save your progress. Try again; your existing history is safe." } }
}

@MainActor struct ResetStartup: View { @State private var session: ResetSession?; @State private var failed = false; @AppStorage("resetWelcome") private var welcome = false
    var body: some View { Group { if !welcome && !ProcessInfo.processInfo.arguments.contains("-skip-onboarding") { ResetWelcome { welcome = true } } else if let session { ResetRoot(session: session) } else if failed { ContentUnavailableView("Reset is unavailable", systemImage: "externaldrive.badge.exclamationmark", description: Text("Your history was not erased. Close and reopen the app, then try again.")) } else { ProgressView().task { do { session = try ResetSession() } catch { failed = true } } } } }
}

@MainActor struct ResetRoot: View { @Bindable var session: ResetSession; @Environment(\.scenePhase) private var phase
    var body: some View { TabView { ResetToday(session: session).tabItem { Label("Today", systemImage: "sparkles") }; ResetProgressView(session: session).tabItem { Label("Progress", systemImage: "chart.bar.xaxis") }; ResetSettings(session: session).tabItem { Label("Settings", systemImage: "slider.horizontal.3") } }.tint(ResetTokens.accent).onChange(of: phase) { _, v in if v == .active { session.perform() } }.alert("Couldn’t update Reset", isPresented: Binding(get: { session.error != nil }, set: { if !$0 { session.error = nil } })) { Button("OK", role: .cancel) {} } message: { Text(session.error ?? "") } }
}

enum ResetTokens {
    static let accent = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.43, green: 0.83, blue: 0.73, alpha: 1)
            : UIColor(red: 0.10, green: 0.37, blue: 0.32, alpha: 1)
    })
    static let action = Color(red: 0.10, green: 0.37, blue: 0.32)
    static let ink = Color.primary
    static var wash: Color { FoundationTokens.background }
}

struct ResetProgressView: View {
    let session: ResetSession
    @State private var selectedDate: Date?
    var body: some View { ScrollView { VStack(alignment: .leading, spacing: 18) {
        HStack(alignment: .bottom) { VStack(alignment: .leading, spacing: 3) { Text("Your rhythm").font(.largeTitle.bold()); Text("Every clear surface leaves a little more calm.").foregroundStyle(FoundationTokens.muted) }; Spacer(); CompanionView(mood: .calm, accent: ResetTokens.accent).frame(width: 72, height: 72) }
        HStack(alignment: .firstTextBaseline) { Text("\(session.progress.streak)").font(.system(size: 48, weight: .bold, design: .rounded)).foregroundStyle(ResetTokens.accent); Text("day streak").font(.headline); Spacer(); Text("Level \(session.progress.level)").font(.subheadline.weight(.semibold)).foregroundStyle(FoundationTokens.muted) }
        HStack(spacing: 8) { ForEach((-3...3), id: \.self) { offset in let date = Calendar.current.date(byAdding: .day, value: offset, to: Date())!; Button { selectedDate = date } label: { VStack(spacing: 7) { Text(date, format: .dateTime.weekday(.narrow)).font(.caption2); Circle().fill(session.progress.history.contains(ResetDay.key(date)) ? ResetTokens.accent : ResetTokens.accent.opacity(0.12)).frame(width: 34, height: 34).overlay { if session.progress.history.contains(ResetDay.key(date)) { Image(systemName: "checkmark").foregroundStyle(.white) } else { Text(date, format: .dateTime.day()).font(.caption) } } } }.buttonStyle(.plain) } }.frame(maxWidth: .infinity)
        HStack(alignment: .top, spacing: 18) { Text("3 resets\n\(session.progress.total >= 3 ? "Plant on the desk" : "Plant detail")").font(.subheadline.weight(.semibold)); Rectangle().fill(ResetTokens.accent.opacity(0.25)).frame(height: 2).padding(.top, 8); Text("7 resets\n\(session.progress.total >= 7 ? "Calmer corner" : "\(session.progress.total)/7")").font(.subheadline.weight(.semibold)) }
    }.padding(20) }.background(ResetTokens.wash).sheet(isPresented: Binding(get: { selectedDate != nil }, set: { if !$0 { selectedDate = nil } })) { if let date = selectedDate { ResetDateDetail(date: date, completed: session.progress.history.contains(ResetDay.key(date)), canCorrect: date < Date()) { session.perform { try $0.complete(on: date) }; selectedDate = nil } } } }
}
