import SwiftUI
import ResetFoundation
import ResetCore

struct ResetWelcome: View {
    let finish: () -> Void
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                CompanionView(mood: .waking, accent: ResetTokens.accent)
                    .frame(height: 118)
                Text("Reset your space").font(.largeTitle.bold())
                Text("Take two minutes to clear your desk. A calmer workspace makes a calmer start.")
                    .font(.title3).foregroundStyle(FoundationTokens.muted)
                DeskScene(level: 1, clean: false)
                Button(action: finish) {
                    Text("Start fresh").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent).controlSize(.large).tint(ResetTokens.action)
            }
            .multilineTextAlignment(.center).padding(24).padding(.top, 24)
        }.background(ResetTokens.wash)
    }
}

struct ResetToday: View {
    let session: ResetSession
    @State private var show = false
    @State private var companionMessage = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("RESET").font(.caption.weight(.bold)).tracking(2).foregroundStyle(ResetTokens.accent)
                    Text("Your desk, reset.").font(.largeTitle.bold())
                }
                Button { withAnimation(.spring(response: 0.35)) { companionMessage.toggle() } } label: {
                    VStack(spacing: 8) {
                        CompanionView(mood: session.completed ? .calm : .idle, accent: ResetTokens.accent).frame(height: 118)
                        Text(companionMessage ? "Mochi is keeping the workspace calm." : session.completed ? "Mochi can finally relax." : "Mochi found a few things out of place.")
                            .font(.subheadline.weight(.medium)).foregroundStyle(.primary)
                    }.frame(maxWidth: .infinity)
                }.buttonStyle(.plain)
                FoundationCard {
                    VStack(spacing: 20) {
                        Label(session.completed ? "Completed today" : "Your daily reset", systemImage: session.completed ? "checkmark.seal.fill" : "sparkles")
                            .font(.subheadline.weight(.semibold)).foregroundStyle(ResetTokens.accent)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        DeskScene(level: session.progress.level, clean: session.completed)
                        if session.completed {
                            Text("Clear mind, clear surface.").font(.title2.bold())
                            Text("Today’s reset is saved. Your workspace is becoming yours.").foregroundStyle(FoundationTokens.muted)
                            Button("Undo today’s reset", role: .destructive) { session.perform { try $0.undoToday() } }
                                .buttonStyle(.bordered).controlSize(.large)
                        } else {
                            Text("Clear the cups, crumbs and small clutter, then sweep to reset.")
                                .font(.body).foregroundStyle(FoundationTokens.muted)
                            SwipeToReset { session.perform { try $0.complete() } }
                            Text("One clean surface. One calmer start.").font(.subheadline.weight(.medium)).foregroundStyle(ResetTokens.accent)
                        }
                    }.multilineTextAlignment(.center)
                }
                ResetMiniProgress(progress: session.progress)
            }.padding(20)
        }
        .background(ResetTokens.wash)
        .sensoryFeedback(.success, trigger: session.celebration)
        .overlay {
            if show {
                Label("Desk reset · +1 day", systemImage: "checkmark.circle.fill")
                    .font(.headline).padding(20).background(.regularMaterial, in: Capsule()).transition(.scale)
            }
        }
        .onChange(of: session.celebration) { _, _ in
            guard session.completed else { return }
            withAnimation { show = true }
            Task { try? await Task.sleep(for: .seconds(1.2)); withAnimation { show = false } }
        }
    }
}

struct SwipeToReset: View {
    let action: () -> Void
    @State private var offset: CGFloat = 0
    var body: some View {
        Label("Swipe to reset", systemImage: "arrow.right")
            .font(.headline).foregroundStyle(.white)
            .frame(maxWidth: .infinity).padding(.vertical, 20)
            .background {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule().fill(ResetTokens.action)
                        Capsule().fill(.white.opacity(0.18))
                            .frame(width: min(geometry.size.width, 56 + offset))
                    }
                }
            }
            .clipShape(Capsule()).contentShape(Capsule())
            .gesture(DragGesture(minimumDistance: 8)
                .onChanged { value in offset = max(0, value.translation.width) }
                .onEnded { value in
                    if value.translation.width > 150 { action() }
                    withAnimation { offset = 0 }
                })
            .accessibilityElement(children: .combine).accessibilityLabel("Reset desk")
            .accessibilityHint("Swipe right to confirm today’s desk reset")
            .accessibilityAction { action() }
    }
}

struct DeskScene: View {
    let level: Int
    let clean: Bool
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Image(systemName: "sun.max.fill").foregroundStyle(ResetTokens.accent)
                Spacer()
                if clean { Label("Reset", systemImage: "checkmark.circle.fill").font(.caption.weight(.semibold)).foregroundStyle(ResetTokens.accent) }
            }
            VStack(spacing: 6) {
                HStack(alignment: .bottom, spacing: 24) {
                    Image(systemName: "lamp.desk.fill").font(.system(size: 34)).foregroundStyle(ResetTokens.accent)
                    Image(systemName: "rectangle.and.pencil.and.ellipsis").font(.system(size: 42)).foregroundStyle(ResetTokens.ink)
                    if level > 1 { Image(systemName: "leaf.fill").font(.system(size: 25)).foregroundStyle(ResetTokens.accent) }
                    if level > 2 { Image(systemName: "cup.and.saucer.fill").font(.system(size: 22)).foregroundStyle(ResetTokens.accent) }
                }.frame(maxWidth: .infinity)
                RoundedRectangle(cornerRadius: 4).fill(ResetTokens.accent.opacity(0.5)).frame(height: 8)
            }
        }
        .padding(22)
        .background(LinearGradient(colors: [ResetTokens.accent.opacity(0.06), ResetTokens.accent.opacity(0.16)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 18))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(clean ? "Clean desk, reset complete" : "Desk ready for today’s reset")
    }
}

struct ResetMiniProgress: View {
    let progress: ResetProgress
    var body: some View {
        FoundationCard {
            ViewThatFits(in: .horizontal) {
                HStack {
                    Label("\(progress.streak)-day streak", systemImage: "flame.fill")
                    Spacer(minLength: 16)
                    Text("Level \(progress.level)")
                }
                VStack(alignment: .leading, spacing: 12) {
                    Label("\(progress.streak)-day streak", systemImage: "flame.fill")
                    Text("Level \(progress.level)")
                }
            }.font(.headline).foregroundStyle(ResetTokens.accent)
        }
    }
}

struct ResetProgressView: View {
    let progress: ResetProgress
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Your rhythm").font(.largeTitle.bold())
                Text("A little space, a little more calm.").foregroundStyle(FoundationTokens.muted)
                HStack(spacing: 16) { CompanionView(mood: .happy, accent: ResetTokens.accent).frame(width: 92, height: 92); VStack(alignment: .leading, spacing: 4) { Text("\(progress.streak) days").font(.title.bold()).monospacedDigit(); Text("Best: \(progress.bestStreak) days").font(.subheadline).foregroundStyle(FoundationTokens.muted) } }
                ResetTimeline(progress: progress)
            }.padding(20)
        }.background(ResetTokens.wash)
    }
}

struct ResetTimeline: View {
    let progress: ResetProgress
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recent resets").font(.headline)
            ForEach(Array((0..<10).reversed().enumerated()), id: \.element) { index, offset in
                let day = Calendar.current.date(byAdding: .day, value: -offset, to: Date())!
                let done = progress.history.contains(ResetDay.key(day))
                HStack(spacing: 14) {
                    VStack(spacing: 0) { Circle().fill(done ? ResetTokens.accent : ResetTokens.accent.opacity(0.18)).frame(width: 18, height: 18).overlay { if done { Image(systemName: "checkmark").font(.caption2.bold()).foregroundStyle(.white) } }; if index < 9 { Rectangle().fill(ResetTokens.accent.opacity(0.18)).frame(width: 2, height: 28) } }
                    VStack(alignment: .leading, spacing: 3) { Text(day, format: .dateTime.weekday(.wide)).font(.body.weight(.medium)); Text(done ? "Workspace settled" : "A day still ahead").font(.caption).foregroundStyle(FoundationTokens.muted) }
                    Spacer()
                }.accessibilityElement(children: .combine).accessibilityLabel("\(day.formatted(date: .complete, time: .omitted)), \(done ? "reset complete" : "not reset")")
            }
        }.padding(18).background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

struct ResetSettings: View {
    let session: ResetSession
    @State private var confirm = false
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Label("Private on this iPhone", systemImage: "lock.shield").font(.headline)
                    Text("Reset stores only your completion history in this app. No account or sync service.").foregroundStyle(FoundationTokens.muted)
                }
                Section("Fresh start") { Button("Reset progress", role: .destructive) { confirm = true } }
                Section { Text("Reset · make space for a clearer mind").font(.footnote).foregroundStyle(FoundationTokens.muted) }
            }.navigationTitle("Settings")
        }
        .confirmationDialog("Delete all progress?", isPresented: $confirm) {
            Button("Delete", role: .destructive) { session.perform { try $0.reset() } }
            Button("Cancel", role: .cancel) {}
        } message: { Text("Your reset history and streak will be permanently deleted from this iPhone.") }
    }
}
