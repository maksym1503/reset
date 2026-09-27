import SwiftUI
import ResetFoundation
import ResetCore

struct ResetWelcome: View {
    let finish: () -> Void
    var body: some View { ScrollView { VStack(spacing: 22) { CompanionView(mood: .waking, accent: ResetTokens.accent).frame(height: 118); Text("Reset your space").font(.largeTitle.bold()); Text("Meet Mochi, then sweep one small surface into calm.").font(.title3).foregroundStyle(FoundationTokens.muted); DeskScene(level: 1, clean: false); Button("Start fresh", action: finish).buttonStyle(.borderedProminent).controlSize(.large).tint(ResetTokens.action) }.multilineTextAlignment(.center).padding(24).padding(.top, 28) }.background(ResetTokens.wash) }
}

struct ResetToday: View {
    let session: ResetSession
    @State private var show = false
    @State private var mood: CompanionMood = .idle
    @State private var notice = "Mochi found a few things out of place."
    var body: some View { ZStack { ResetWorld(level: session.progress.level, clean: session.completed); ScrollView(showsIndicators: false) { VStack(alignment: .leading, spacing: 14) {
        HStack(alignment: .bottom) { VStack(alignment: .leading, spacing: 3) { Text("Reset your space").font(.largeTitle.bold()); Text(Date(), format: .dateTime.weekday(.wide)).font(.subheadline.weight(.semibold)).foregroundStyle(ResetTokens.accent) }; Spacer(); Text("\(session.progress.streak) days").font(.subheadline.weight(.bold)).foregroundStyle(ResetTokens.accent) }
        Button { mood = session.completed ? .happy : .curious; notice = session.completed ? "Mochi is resting in the quiet." : "Mochi is watching the clutter move." } label: { VStack(spacing: 3) { CompanionView(mood: session.completed ? .calm : mood, accent: ResetTokens.accent).frame(height: 118); Text(notice).font(.subheadline.weight(.medium)).foregroundStyle(.primary) }.frame(maxWidth: .infinity) }.buttonStyle(.plain)
        DeskScene(level: session.progress.level, clean: session.completed)
        if session.completed { Text("The desk is calm because you made it calm.").font(.title3.bold()).frame(maxWidth: .infinity); Button("Undo today’s reset", role: .destructive) { session.perform { try $0.undoToday() } }.frame(maxWidth: .infinity) }
        else { Text("Sweep across the desk. One clean pass is enough.").font(.body).foregroundStyle(FoundationTokens.muted).frame(maxWidth: .infinity).multilineTextAlignment(.center); SwipeToReset { session.perform { try $0.complete() } } }
    }.padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 28) } }
        .sensoryFeedback(.success, trigger: session.celebration).overlay { if show { ResetReward().transition(.scale) } }.onChange(of: session.celebration) { _, _ in guard session.completed else { return }; mood = .celebration; withAnimation(.spring(response: 0.3)) { show = true }; Task { try? await Task.sleep(for: .seconds(1.3)); withAnimation { show = false } } }
    }
}

struct ResetWorld: View { let level: Int; let clean: Bool; var body: some View { GeometryReader { g in ZStack(alignment: .bottom) { LinearGradient(colors: [FoundationTokens.sceneTop, FoundationTokens.sceneBottom], startPoint: .topLeading, endPoint: .bottomTrailing); Circle().fill(ResetTokens.accent.opacity(clean ? 0.22 : 0.10)).frame(width: 220).position(x: g.size.width * 0.82, y: g.size.height * 0.18); VStack { Spacer(); HStack { Image(systemName: "lamp.desk.fill").font(.system(size: 36)).foregroundStyle(.white.opacity(0.28)); Spacer(); if level > 1 { Image(systemName: "leaf.fill").font(.system(size: 30)).foregroundStyle(.white.opacity(0.32)) } }.padding(.horizontal, 36).padding(.bottom, 12); Rectangle().fill(.black.opacity(0.28)).frame(height: g.size.height * 0.25) } }.ignoresSafeArea() }.allowsHitTesting(false) } }

struct SwipeToReset: View {
    let action: () -> Void; @State private var offset: CGFloat = 0
    var body: some View { GeometryReader { geo in ZStack(alignment: .leading) { Capsule().fill(ResetTokens.action.opacity(0.94)); Capsule().fill(.white.opacity(0.18)).frame(width: min(geo.size.width, max(64, 64 + offset))); HStack { Image(systemName: "hand.draw.fill"); Text("Sweep to clear the desk"); Spacer(); Image(systemName: "arrow.right") }.font(.headline).foregroundStyle(.white).padding(.horizontal, 20) }.clipShape(Capsule()).contentShape(Capsule()).gesture(DragGesture(minimumDistance: 4).onChanged { value in offset = min(max(0, value.translation.width), geo.size.width - 20) }.onEnded { value in if value.translation.width > geo.size.width * 0.52 { withAnimation(.spring(response: 0.25)) { offset = geo.size.width }; action() } else { withAnimation(.spring(response: 0.28)) { offset = 0 } } }).accessibilityElement(children: .combine).accessibilityLabel("Reset desk").accessibilityHint("Sweep right to clear the desk").accessibilityAction { action() } }.frame(height: 58) }
}

struct DeskScene: View {
    let level: Int; let clean: Bool
    var body: some View { VStack(spacing: 14) { HStack { Text(clean ? "CALM" : "CLUTTER").font(.caption.weight(.bold)).tracking(2).foregroundStyle(ResetTokens.accent); Spacer(); Text(clean ? "settled" : "ready").font(.caption).foregroundStyle(FoundationTokens.muted) }; HStack(alignment: .bottom, spacing: 24) { Image(systemName: "lamp.desk.fill").font(.system(size: 38)).foregroundStyle(ResetTokens.accent); Image(systemName: clean ? "rectangle.and.pencil.and.ellipsis" : "cup.and.saucer.fill").font(.system(size: 46)).foregroundStyle(ResetTokens.ink); if level > 1 { Image(systemName: "leaf.fill").font(.system(size: 28)).foregroundStyle(ResetTokens.accent) }; if level > 2 { Image(systemName: "note.text").font(.system(size: 25)).foregroundStyle(ResetTokens.accent) } }.frame(maxWidth: .infinity).padding(.vertical, 28); Rectangle().fill(ResetTokens.accent.opacity(clean ? 0.75 : 0.38)).frame(height: 8) }.accessibilityElement(children: .ignore).accessibilityLabel(clean ? "Calm desk, reset complete" : "Cluttered desk ready for reset") }
}

struct ResetReward: View { var body: some View { VStack(spacing: 6) { CompanionView(mood: .celebration, accent: ResetTokens.accent).frame(height: 112); Text("+1 calm day").font(.title2.bold()); Text("The workspace settled.").font(.callout) }.padding(22).background(.ultraThinMaterial, in: Capsule()).shadow(radius: 18).accessibilityElement(children: .combine).accessibilityLabel("Desk reset complete. One calm day added.") } }

struct ResetSettings: View { let session: ResetSession; @State private var confirm = false; var body: some View { NavigationStack { Form { Section { Label("Private on this iPhone", systemImage: "lock.shield").font(.headline); Text("Reset stores only your completion history in this app. No account or sync service.").foregroundStyle(FoundationTokens.muted) }; Section("Fresh start") { Button("Reset progress", role: .destructive) { confirm = true } }; Section { Text("Reset · make space for a clearer mind").font(.footnote).foregroundStyle(FoundationTokens.muted) } }.navigationTitle("Settings") }.confirmationDialog("Delete all progress?", isPresented: $confirm) { Button("Delete", role: .destructive) { session.perform { try $0.reset() } }; Button("Cancel", role: .cancel) {} } message: { Text("Your reset history and streak will be permanently deleted from this iPhone.") } } }
