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
    public let action: () -> Void
    public let art: (CGFloat) -> Art
    @State private var reaction: CompanionMood?
    @State private var taps = 0
    @State private var reward = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var phase
    public init(completed: Bool, progress: CGFloat = 0, label: String, hint: String, palette: WorldPalette,
                companionPoint: UnitPoint, target: CGRect, restingMood: CompanionMood, active: Bool = true,
                action: @escaping () -> Void, @ViewBuilder art: @escaping (CGFloat) -> Art) {
        self.completed = completed; self.progress = progress; self.label = label; self.hint = hint; self.palette = palette
        self.companionPoint = companionPoint; self.target = target; self.restingMood = restingMood
        self.active = active; self.action = action; self.art = art
    }
    private var amount: CGFloat {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-qa-drag") && !completed { return 0.55 }
        #endif
        return completed ? 1 : progress
    }
    public var body: some View {
        GeometryReader { g in
            ZStack {
                art(amount)
                    .animation(reduceMotion ? nil : .spring(response: 0.42, dampingFraction: 0.82), value: completed)
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
                    CompanionView(mood: progress > 0 || amount > 0 && !completed ? .helping : reaction ?? (completed ? .calm : restingMood),
                                  accent: palette.accent, active: active)
                        .frame(width: g.size.width * 0.29, height: g.size.width * 0.32)
                }.buttonStyle(.plain)
                    .offset(x: (companionPoint.x > 0.5 ? -1 : 1) * g.size.width * (completed ? 0 : amount) * 0.07)
                    .position(x: g.size.width * companionPoint.x, y: g.size.height * companionPoint.y)
                    .accessibilityLabel("Mochi").accessibilityHint("Say hello").accessibilityIdentifier("mochi")
                if !completed {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 20, weight: .bold)).foregroundStyle(.white)
                        .shadow(color: palette.action, radius: 3)
                        .position(x: g.size.width * (target.midX + 0.06 * amount), y: g.size.height * (target.midY + 0.04))
                        .allowsHitTesting(false).accessibilityHidden(true)
                }
                if reward {
                    Text("Lovely. That’s today done.")
                        .font(.headline).foregroundStyle(palette.ink)
                        .padding(.horizontal,16).padding(.vertical,10)
                        .frame(maxWidth: g.size.width - 40)
                        .multilineTextAlignment(.center)
                        .background(.regularMaterial, in: Capsule())
                        .position(x: g.size.width / 2, y: g.size.height * 0.13)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
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
                try await Task.sleep(for: .seconds(1.8))
                withAnimation(reduceMotion ? nil : .snappy) { reward = false }
                reaction = nil
            } catch {}
        }
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
