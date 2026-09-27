import SwiftUI
import ResetFoundation
import ResetCore

@MainActor struct ResetProgressView: View {
    let session: ResetSession
    @Environment(\.colorScheme) private var scheme
    @State private var historyPresented = false
    private var p: WorldPalette { WorldPalette(.focus, scheme) }
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                WorldHeader("Look how far.", subtitle: "Small resets make a difference.", palette: p)
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .firstTextBaseline, spacing: 10) { streak; Spacer(minLength: 8); level }
                    VStack(alignment: .leading, spacing: 6) { streak; level }
                }
                HistoryCalendar(today: ResetDay.date(session.day) ?? Date(),
                    completed: Set(session.progress.history), key: { ResetDay.key($0) },
                    palette: p, completedCopy: "Desk reset.", rewardCopy: "One more reset in your story.",
                    presented: $historyPresented, edit: session.editHistory)
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Your workspace, so far").font(WorldType.title).fixedSize()
                        Spacer()
                        Text("\(session.progress.total) \(session.progress.total == 1 ? "reset" : "resets")").font(.subheadline).foregroundStyle(p.secondary).fixedSize()
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Your workspace, so far").font(WorldType.title)
                        Text("\(session.progress.total) \(session.progress.total == 1 ? "reset" : "resets")").font(.subheadline).foregroundStyle(p.secondary)
                    }
                }
                ZStack(alignment: .bottomTrailing) {
                    WorkspaceArtwork(progress: 1, level: session.progress.level, palette: p)
                        .frame(height: 410).frame(height: 300, alignment: .bottom).clipped()
                    CompanionView(mood: .proud, accent: p.accent, active: !historyPresented)
                        .frame(width: 84,height: 95).padding(.trailing,16).padding(.bottom,18)
                }.frame(height: 300).padding(.horizontal, -24).accessibilityLabel("Your workspace at level \(session.progress.level)")
                UnlockGallery(total: session.progress.total, thresholds: [5,10,15],
                    titles: ["Desk plant","Studio print","Bookshelf"], palette: p)
                VStack(alignment: .leading, spacing: 5) {
                    Text("Seven fresh starts").font(.headline)
                    Text("\(min(session.progress.total, 7)) of 7 resets. Any days count.")
                        .font(.subheadline).foregroundStyle(p.secondary)
                    Text("Best streak: \(session.progress.bestStreak) \(session.progress.bestStreak == 1 ? "day" : "days")")
                        .font(.caption).foregroundStyle(p.secondary)
                }.padding(.vertical,6)
            }.padding(24)
        }.clipped().foregroundStyle(p.ink).background(p.paper).tint(p.accent)
    }
    private var streak: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text("\(session.progress.streak)").font(WorldType.metric).monospacedDigit()
            Text("day streak").font(.subheadline.weight(.medium))
        }
    }
    private var level: some View {
        Text("Level \(session.progress.level)")
            .font(.subheadline.weight(.semibold)).foregroundStyle(p.accent).fixedSize(horizontal: false,vertical: true)
    }
}
