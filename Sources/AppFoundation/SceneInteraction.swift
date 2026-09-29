import SwiftUI

/// The hit region is a physical scene object, with no slider track or competing long press.
public struct SceneInteraction<Art: View>: View {
    public let completed: Bool
    public let progress: CGFloat
    public let label: String
    public let hint: String
    public let palette: WorldPalette
    public let companionPoint: UnitPoint
    public let target: CGRect
    public let restingMood: CompanionMood
    public let active: Bool
    public let achievement: String?
    public let action: () -> Void
    public let art: (CGFloat) -> Art
    @State private var reaction: CompanionMood?
    @State private var taps = 0
    @State private var reward = false
    @State private var cueTravel: CGFloat = 0
    @State private var visible = false
    private var cueRunning: Bool { visible && active && phase == .active && !reduceMotion && !completed && progress == 0 }
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var phase
    public init(completed: Bool, progress: CGFloat = 0, label: String, hint: String, palette: WorldPalette,
                companionPoint: UnitPoint, target: CGRect, restingMood: CompanionMood, active: Bool = true,
                achievement: String? = nil,
                action: @escaping () -> Void, @ViewBuilder art: @escaping (CGFloat) -> Art) {
        self.completed = completed; self.progress = progress; self.label = label; self.hint = hint; self.palette = palette
        self.companionPoint = companionPoint; self.target = target; self.restingMood = restingMood
        self.active = active; self.achievement = achievement; self.action = action; self.art = art
    }
    private var amount: CGFloat {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-qa-drag") && !completed { return 0.55 }
        #endif
        return completed ? 1 : progress
    }
    private var directionCue: some View {
        HStack(spacing: 12) {
            Image(systemName: "hand.draw.fill").font(.system(size: 20, weight: .medium))
                .offset(x: cueTravel)
            Image(systemName: "arrow.right").font(.system(size: 22, weight: .semibold))
        }.frame(width: 90, height: 26)
    }

    public var body: some View {
        GeometryReader { g in
            ZStack {
                art(amount)
                    .animation(reduceMotion ? nil : .spring(response: 0.42, dampingFraction: 0.82), value: completed)
                WindowAtmosphere(palette: palette, active: active && !reward)
                Color.clear.contentShape(Rectangle())
                    .frame(width: g.size.width * target.width, height: g.size.height * target.height)
                    .background {
                        GeometryReader { object in
                            Color.clear.preference(key: RitualRegionKey.self,
                                value: RitualRegion(frame: object.frame(in: .global), sceneWidth: g.size.width))
                        }
                    }
                    .accessibilityElement()
                    .accessibilityLabel(completed ? "Completed today" : label)
                    .accessibilityHint(hint)
                    .accessibilityAddTraits(.isButton)
                    .accessibilityIdentifier("ritual-object")
                    .accessibilityAction { if !completed { action() } }
                    .position(x: g.size.width * target.midX, y: g.size.height * target.midY)
                Button { taps += 1; reaction = completed ? (taps.isMultiple(of: 2) ? .proud : .celebration) : (taps.isMultiple(of: 2) ? .waking : .curious) } label: {
                    CompanionView(mood: achievement != nil ? .celebration : progress > 0 || amount > 0 && !completed ? .helping : reaction ?? (completed ? .calm : restingMood),
                                  accent: palette.accent, active: active)
                        .frame(width: g.size.width * 0.29, height: g.size.width * 0.32)
                }.buttonStyle(CompanionPressStyle())
                    .offset(x: (companionPoint.x > 0.5 ? -1 : 1) * g.size.width * (completed ? 0 : amount) * 0.07)
                    .position(x: g.size.width * companionPoint.x, y: g.size.height * companionPoint.y)
                    .accessibilityLabel("Mochi").accessibilityHint("Say hello").accessibilityIdentifier("mochi")
                if !completed {
                    Group {
                        if palette.tone == .morning {
                            VStack(spacing: 5) {
                                Text("Pull to finish").font(.subheadline.weight(.bold))
                                directionCue
                            }
                        } else {
                            HStack(spacing: 12) {
                                Text("Sweep").font(.subheadline.weight(.bold))
                                directionCue
                            }
                        }
                    }
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    .foregroundStyle(Color.white)
                    .shadow(color: .black.opacity(0.4), radius: 2, y: 1)
                    .opacity(max(0, 1 - Double(amount) * 6))
                    .position(x: g.size.width * (palette.tone == .morning ? 0.51 : 0.60),
                              y: g.size.height * (palette.tone == .morning ? 0.74 : 0.73))
                    .allowsHitTesting(false).accessibilityHidden(true)
                }
                if reward {
                    if let achievement {
                        MilestoneMoment(title: achievement, palette: palette, reduceMotion: reduceMotion)
                            .frame(width: g.size.width, height: g.size.height)
                            .transition(.opacity)
                            .accessibilityIdentifier("milestone-celebration")
                    } else {
                        CompletionBloom(palette: palette, reduceMotion: reduceMotion)
                            .frame(width: g.size.width * 0.8, height: g.size.height * 0.48)
                            .position(x: g.size.width * 0.53, y: g.size.height * 0.61)
                            .allowsHitTesting(false).accessibilityHidden(true)
                        Text(palette.tone == .morning ? "A bright start!" : "And… exhale.")
                            .font(WorldType.title).foregroundStyle(palette.ink)
                            .multilineTextAlignment(.center).padding(.horizontal, 24)
                            .position(x: g.size.width / 2, y: g.size.height * 0.42)
                            .transition(.opacity)
                            .accessibilityIdentifier("completion-reward")
                    }
                }
            }
        }
        .onAppear { visible = true }
        .onDisappear { visible = false; reward = false; reaction = nil }
        .task(id: cueRunning) {
            guard cueRunning else { cueTravel = 0; return }
            do {
                // One demonstration, then long quiet intervals. A drag cancels this task.
                while !Task.isCancelled {
                    try await Task.sleep(for: .seconds(1.2))
                    withAnimation(.smooth(duration: 0.8)) { cueTravel = 17 }
                    try await Task.sleep(for: .seconds(0.9))
                    withAnimation(.smooth(duration: 0.3)) { cueTravel = 0 }
                    try await Task.sleep(for: .seconds(6))
                }
            } catch { cueTravel = 0 }
        }
        .sensoryFeedback(.success, trigger: completed) { old, new in !old && new }
        .sensoryFeedback(.selection, trigger: taps)
        .task(id: taps) {
            guard taps > 0 else { return }
            do { try await Task.sleep(for: .seconds(1.6)); reaction = nil } catch {}
        }
        .onChange(of: completed) { _, value in
            reaction = value ? .celebration : nil
            withAnimation(reduceMotion ? nil : .snappy) { reward = value }
        }
        .task(id: reward) {
            guard reward else { return }
            do {
                try await Task.sleep(for: .seconds(2.6))
                withAnimation(reduceMotion ? nil : .snappy) { reward = false }
                reaction = nil
            } catch {}
        }
        .onChange(of: active) { _, value in if !value { reaction = nil; reward = false } }
        .onChange(of: phase) { _, value in if value != .active { reaction = nil; reward = false } }
    }
}

public struct WorldHeader: View {
    public let title: String
    public let subtitle: String
    public let palette: WorldPalette
    public init(_ title: String, subtitle: String, palette: WorldPalette) {
        self.title = title; self.subtitle = subtitle; self.palette = palette
    }
    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(WorldType.hero).fixedSize(horizontal: false, vertical: true)
            Text(subtitle).font(.subheadline).foregroundStyle(palette.secondary).fixedSize(horizontal: false, vertical: true)
        }.foregroundStyle(palette.ink)
    }
}


private struct RitualRegion: Equatable {
    var frame = CGRect.zero
    var sceneWidth: CGFloat = 1
}
private struct RitualRegionKey: PreferenceKey {
    static var defaultValue: RitualRegion { RitualRegion() }
    static func reduce(value: inout RitualRegion, nextValue: () -> RitualRegion) {
        let next = nextValue()
        if next.frame != .zero { value = next }
    }
}

/// Attach the drag alongside the ScrollView's own pan, not to a descendant.
/// iOS 26 does not make a descendant simultaneousGesture simultaneous with ancestors.
public struct RitualScrollView<Content: View>: View {
    let completed: Bool
    let action: () -> Void
    let content: (CGFloat) -> Content
    @GestureState private var progress: CGFloat = 0
    @State private var region = RitualRegion()
    public init(completed: Bool, action: @escaping () -> Void,
                @ViewBuilder content: @escaping (CGFloat) -> Content) {
        self.completed = completed; self.action = action; self.content = content
    }
    public var body: some View {
        ScrollView(showsIndicators: false) { content(progress) }
            .onPreferenceChange(RitualRegionKey.self) { region = $0 }
            .simultaneousGesture(DragGesture(minimumDistance: 3, coordinateSpace: .global)
                .updating($progress) { value, state, transaction in
                    guard !completed, region.frame.contains(value.startLocation),
                          abs(value.translation.width) > abs(value.translation.height) else { return }
                    transaction.animation = nil
                    state = min(1, max(0, value.translation.width / (region.sceneWidth * 0.30)))
                }
                .onEnded { value in
                    guard !completed, region.frame.contains(value.startLocation),
                          value.translation.width >= region.sceneWidth * 0.20,
                          abs(value.translation.width) > abs(value.translation.height) * 1.2 else { return }
                    action()
                })
    }
}
