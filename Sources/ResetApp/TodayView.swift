import SwiftUI
import ResetFoundation
import ResetCore

struct ResetToday: View {
    @State private var rewardPresented = false
    @State private var achievementTitle: String?
    let session: ResetSession
    @Environment(\.colorScheme) private var scheme
    private var p: WorldPalette { WorldPalette(.focus, scheme) }
    var body: some View {
        GeometryReader { geometry in
            let sceneHeight = max(360, min(560, geometry.size.height - 200))
            RitualScrollView(completed: session.completed, action: { session.perform { try $0.complete() } }) { progress in
                VStack(spacing: 0) {
                    WorldHeader("Make a little space.", subtitle: Date().formatted(.dateTime.weekday(.wide).month(.abbreviated).day()), palette: p)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal,24).padding(.top,16).padding(.bottom,12).background(p.wall)
                    SceneInteraction(completed: session.completed, progress: progress, label: "Reset desk",
                        hint: "Sweep the desktop to the right. Or double tap to complete.",
                        palette: p, companionPoint: UnitPoint(x: 0.22,y: 0.73),
                        target: CGRect(x: 0.29,y: 0.60,width: 0.64,height: 0.16), restingMood: .curious, active: !rewardPresented,
                        achievement: achievementTitle,
                        action: { session.perform { try $0.complete() } }) { progress in
                            WorkspaceArtwork(progress: progress, level: session.progress.level, palette: p)
                        }
                        .frame(height: sceneHeight)
                    VStack(spacing: 0) {
                        RitualKeepsake(total: session.progress.total, completed: session.completed, palette: p,
                            undoTitle: "Undo today’s reset", undo: { session.perform { try $0.undoToday() } },
                            onPresentationChange: { rewardPresented = $0 })
                        Spacer(minLength: 0)
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(WorldForeground(palette: p, sceneHeight: sceneHeight))
                }.frame(minHeight: geometry.size.height, alignment: .top)
            }
            .onChange(of: session.progress.total) { oldTotal, newTotal in
                guard newTotal > oldTotal else { achievementTitle = nil; return }
                achievementTitle = WorldRewards.achievement(total: newTotal, tone: p.tone)
            }
            .task(id: achievementTitle) {
                guard achievementTitle != nil else { return }
                do { try await Task.sleep(for: .seconds(3.4)); achievementTitle = nil } catch {}
            }
            .clipped().background {
                VStack(spacing: 0) { p.wall; p.floor }.ignoresSafeArea()
            }
        }.foregroundStyle(p.ink).tint(p.accent)
    }
}

struct ResetWelcome: View {
    let finish: () -> Void
    @Environment(\.colorScheme) private var scheme
    private var p: WorldPalette { WorldPalette(.focus, scheme) }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                WorldHeader("A little space.\nA fresh perspective.", subtitle: "Meet Mochi, your desk-side companion.", palette: p)
                ZStack(alignment: .bottomLeading) {
                    WorkspaceArtwork(progress: 0,level: 1,palette: p).frame(height: 350)
                    CompanionView(mood: .waking,accent: p.accent).frame(width: 120,height: 130).padding(.leading,30).padding(.bottom,35)
                }
                Text("Clear your desk. Sweep to log it. Watch this little workspace become yours.")
                    .font(.body).foregroundStyle(p.secondary)
                Button("Meet your workspace",action: finish).font(WorldType.action).buttonStyle(.borderedProminent).controlSize(.large).tint(p.action).foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }.padding(24)
        }.foregroundStyle(p.ink).background(p.paper)
    }
}

struct ResetSettings: View {
    let session: ResetSession
    @State private var confirm = false
    @Environment(\.colorScheme) private var scheme
    private var p: WorldPalette { WorldPalette(.focus, scheme) }
    var body: some View {
        NavigationStack {
            Form {
                Section("On this iPhone") { Text("Your history stays here. No account needed.").foregroundStyle(p.secondary) }
                Section("Start again") {
                    Button("Reset progress",role: .destructive) { confirm = true }
                    Text("Deletes all recorded resets from this iPhone.").font(.footnote).foregroundStyle(p.secondary)
                }
            }.scrollContentBackground(.hidden).background(p.paper).navigationTitle("Settings").tint(p.accent)
        }.confirmationDialog("Delete all progress?",isPresented: $confirm) {
            Button("Delete",role: .destructive) { session.perform { try $0.reset() } }
            Button("Cancel",role: .cancel) {}
        } message: { Text("Your reset history will be permanently deleted.") }
    }
}
