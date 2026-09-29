import SwiftUI

/// Press feedback never changes opacity: Mochi stays solid even while a finger is down.
public struct CompanionPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label.scaleEffect(configuration.isPressed && !reduceMotion ? 0.96 : 1)
            .animation(reduceMotion ? nil : .spring(response: 0.22, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// Reusable greeting with the same proportions and touch behavior in Progress and Today.
public struct CompanionGreeting: View {
    public let palette: WorldPalette
    public let active: Bool
    @State private var taps = 0
    @State private var greeting = false
    public init(palette: WorldPalette, active: Bool = true) { self.palette = palette; self.active = active }
    public var body: some View {
        Button { taps += 1; greeting = true } label: {
            CompanionView(mood: greeting ? (taps.isMultiple(of: 2) ? .curious : .celebration) : .proud,
                          accent: palette.accent, active: active)
        }.buttonStyle(CompanionPressStyle()).accessibilityLabel("Mochi").accessibilityHint("Say hello")
            .accessibilityIdentifier("mochi-progress")
            .sensoryFeedback(.selection, trigger: taps)
            .task(id: taps) {
                guard taps > 0 else { return }
                do { try await Task.sleep(for: .seconds(1.6)); greeting = false } catch {}
            }
    }
}

/// Quiet cloud movement is confined to the window, with long rests between passes.
/// Native interpolation runs only during a pass; there is no display-rate state timer.
public struct WindowAtmosphere: View {
    public let palette: WorldPalette
    public let active: Bool
    @Environment(\.scenePhase) private var phase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var visible = false
    @State private var drift: CGFloat = 0
    private var running: Bool { visible && active && phase == .active && !reduceMotion }
    public init(palette: WorldPalette, active: Bool = true) { self.palette = palette; self.active = active }
    public var body: some View {
        GeometryReader { g in
            let morning = palette.tone == .morning
            CloudWisp().fill(palette.cream.opacity(palette.dark ? 0.22 : 0.65))
                .frame(width: g.size.width * 0.1, height: g.size.height * 0.028)
                .offset(x: drift * g.size.width * 0.025)
                .position(x: g.size.width * (morning ? 0.225 : 0.67),
                          y: g.size.height * (morning ? 0.19 : 0.185))
        }.allowsHitTesting(false).accessibilityHidden(true)
            .onAppear { visible = true }.onDisappear { visible = false }
            .task(id: running) {
                guard running else { drift = 0; return }
                do {
                    while !Task.isCancelled {
                        withAnimation(.easeInOut(duration: 4)) { drift = 1 }
                        try await Task.sleep(for: .seconds(4.5))
                        withAnimation(.easeInOut(duration: 4)) { drift = 0 }
                        try await Task.sleep(for: .seconds(12))
                    }
                } catch { drift = 0 }
            }
    }
}
private struct CloudWisp: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let w = r.width, h = r.height
        p.move(to: CGPoint(x: 0, y: h * 0.8))
        p.addCurve(to: CGPoint(x: w * 0.3, y: h * 0.3), control1: CGPoint(x: 0,y: h * 0.25), control2: CGPoint(x: w * 0.1,y: h * 0.15))
        p.addCurve(to: CGPoint(x: w * 0.73, y: h * 0.45), control1: CGPoint(x: w * 0.35,y: -h * 0.4), control2: CGPoint(x: w * 0.68,y: -h * 0.2))
        p.addCurve(to: CGPoint(x: w,y: h * 0.8), control1: CGPoint(x: w * 0.9,y: h * 0.2), control2: CGPoint(x: w,y: h * 0.4))
        p.addQuadCurve(to: CGPoint(x: 0,y: h * 0.8), control: CGPoint(x: w * 0.5,y: h * 1.1))
        return p
    }
}

/// A single short burst after a committed completion. Reduce Motion gets a static halo.
struct CompletionBloom: View {
    let palette: WorldPalette
    let reduceMotion: Bool
    @State private var flight: CGFloat = 0
    var body: some View {
        BurstDrawing(flight: reduceMotion ? 0.5 : flight, palette: palette)
            .opacity(reduceMotion ? 0.65 : 1)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeOut(duration: 1.25)) { flight = 1 }
            }
    }
}
private struct BurstDrawing: View, Animatable {
    var flight: CGFloat
    let palette: WorldPalette
    var animatableData: CGFloat { get { flight } set { flight = newValue } }
    var body: some View {
        Canvas { context, size in
            drawRays(in: context, size: size)
        }
    }

    private func drawRays(in context: GraphicsContext, size: CGSize) {
        let radius: CGFloat = (0.12 + flight * 0.4) * min(size.width, size.height)
        let opacity: Double = 1 - Double(flight)
        let stroke = StrokeStyle(lineWidth: 3, lineCap: .round)
        for index in 0..<12 {
            let angle: Double = Double(index) * Double.pi / 6
            let dx = CGFloat(cos(angle))
            let dy = CGFloat(sin(angle))
            let origin = CGPoint(x: size.width / 2 + dx * radius,
                                 y: size.height / 2 + dy * radius - flight * 25)
            let end = CGPoint(x: origin.x + dx * 9, y: origin.y + dy * 9)
            var ray = Path()
            ray.move(to: origin)
            ray.addLine(to: end)
            let color: Color = index.isMultiple(of: 2) ? palette.gold : palette.cream
            context.stroke(ray, with: .color(color.opacity(opacity)), style: stroke)
        }
    }
}
