import SwiftUI
import ResetFoundation
import ResetCore

struct ResetWelcome: View {
    let finish: () -> Void
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 52, weight: .medium))
                    .foregroundStyle(ResetTokens.accent)
                    .frame(width: 108, height: 108)
                    .background(ResetTokens.accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 28))
                    .accessibilityHidden(true)
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
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("RESET").font(.caption.weight(.bold)).tracking(2).foregroundStyle(ResetTokens.accent)
                    Text("Your desk, reset.").font(.largeTitle.bold())
                }
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
                Text("Progress").font(.largeTitle.bold())
                Text("A little space, a little more calm.").foregroundStyle(FoundationTokens.muted)
                FoundationCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Your rhythm", systemImage: "flame.fill").font(.headline).foregroundStyle(ResetTokens.accent)
                        Text("\(progress.streak) days").font(.largeTitle.bold()).monospacedDigit()
                        Text("Best streak: \(progress.bestStreak) days").font(.subheadline).foregroundStyle(FoundationTokens.muted)
                    }
                }
                FoundationCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent resets").font(.headline)
                        ForEach((0..<7).reversed(), id: \.self) { i in
                            let day = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
                            let done = progress.history.contains(ResetDay.key(day))
                            HStack {
                                Text(day, format: .dateTime.weekday(.wide))
                                Spacer(minLength: 12)
                                Image(systemName: done ? "checkmark.circle.fill" : "circle")
                                    .font(.title3).foregroundStyle(done ? ResetTokens.accent : FoundationTokens.muted)
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("\(day.formatted(date: .complete, time: .omitted)), \(done ? "reset complete" : "not reset")")
                            if i != 0 { Divider() }
                        }
                    }
                }
            }.padding(20)
        }.background(ResetTokens.wash)
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
