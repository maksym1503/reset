import SwiftUI
import ResetFoundation
import ResetCore

@MainActor struct ResetProgressView: View {
    let session: ResetSession
    @Environment(\.colorScheme) private var scheme
    @State private var rewardPresented = false
    @State private var historyPresented = false
    private var p: WorldPalette { WorldPalette(.focus, scheme) }
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Your little world").font(WorldType.hero)
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
                            Text("Your workspace").font(WorldType.title).fixedSize()
                            Spacer()
                            Text("\(session.progress.total) \(session.progress.total == 1 ? "reset" : "resets")").font(.subheadline).foregroundStyle(p.secondary).fixedSize()
                        }
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Your workspace").font(WorldType.title)
                            Text("\(session.progress.total) \(session.progress.total == 1 ? "reset" : "resets")").font(.subheadline).foregroundStyle(p.secondary)
                        }
                    }
                    Text(WorldRewards.nextSummary(total: session.progress.total, tone: p.tone))
                        .font(.subheadline.weight(.medium)).foregroundStyle(p.accent)
                        .fixedSize(horizontal: false, vertical: true)
                }.padding(24).background(p.wall)
                ZStack(alignment: .bottomTrailing) {
                    WorkspaceArtwork(progress: 1, level: session.progress.level, palette: p)

                    WindowAtmosphere(palette: p, active: !historyPresented && !rewardPresented)
                    CompanionGreeting(palette: p, active: !historyPresented && !rewardPresented)
                        .frame(width: 100,height: 107).padding(.trailing,16).padding(.bottom,18)
                }.aspectRatio(400.0 / 440.0, contentMode: .fit).accessibilityLabel("Your workspace at level \(session.progress.level)")
                VStack(alignment: .leading, spacing: 22) {
                    UnlockGallery(total: session.progress.total, thresholds: WorldRewards.thresholds,
                        titles: WorldRewards.titles(p.tone), palette: p, onPresentationChange: { rewardPresented = $0 })
                    RitualTrail(count: min(session.progress.total, 7), best: session.progress.bestStreak, palette: p)
                }.padding(24).frame(maxWidth: .infinity, alignment: .leading)
                    .background { GeometryReader { g in WorldForeground(palette: p, sceneHeight: g.size.width * 1.1) } }
            }
        }.clipped().foregroundStyle(p.ink).background { VStack(spacing: 0) { p.wall; p.floor }.ignoresSafeArea() }.tint(p.accent)
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
