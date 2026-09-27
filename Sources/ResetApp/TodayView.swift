import SwiftUI
import ResetFoundation
import ResetCore

struct ResetToday: View {
    let session: ResetSession
    @Environment(\.colorScheme) private var scheme
    private var p: WorldPalette { WorldPalette(.focus, scheme) }
    var body: some View {
        GeometryReader { geometry in
            RitualScrollView(completed: session.completed, action: { session.perform { try $0.complete() } }) { progress in
                VStack(spacing: 0) {
                    WorldHeader("Make a little space.", subtitle: Date().formatted(.dateTime.weekday(.wide).month(.abbreviated).day()), palette: p)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal,24).padding(.top,16).padding(.bottom,12)
                    SceneInteraction(completed: session.completed, progress: progress, label: "Reset desk",
                        hint: "Sweep the desktop to the right. Or double tap to complete.",
                        palette: p, companionPoint: UnitPoint(x: 0.22,y: 0.73),
                        target: CGRect(x: 0.29,y: 0.60,width: 0.64,height: 0.16), restingMood: .curious,
                        action: { session.perform { try $0.complete() } }) { progress in
                            WorkspaceArtwork(progress: progress, level: session.progress.level, palette: p)
                        }
                        .frame(height: max(360,min(560,geometry.size.height - 237)))
                    VStack(spacing: 9) {
                        Text(session.completed ? "Clear desk. Fresh perspective." : "A little less clutter.")
                            .font(WorldType.title).multilineTextAlignment(.center)
                        Text(session.completed ? "Today’s reset is saved. Enjoy the space." : "Clear your desk, then sweep right to log your reset.")
                            .font(.subheadline).foregroundStyle(p.secondary).multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        if session.completed {
                            Button("Undo today’s reset", role: .destructive) { session.perform { try $0.undoToday() } }
                                .font(.subheadline).frame(minHeight: 44)
                        } else {
                            Text("Mochi will take care of the finishing touches.")
                                .font(.caption).foregroundStyle(p.secondary).padding(.top,6)
                        }
                    }.padding(.horizontal,26).padding(.vertical,18)
                    Spacer(minLength: 0)
                }.frame(minHeight: geometry.size.height, alignment: .top)
            }.clipped().background(p.paper)
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
