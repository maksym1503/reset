import SwiftUI

/// Shared, independently vendored presentation primitives. No persistence or reward rules.
public enum WorldTone: Sendable { case morning, focus }

public struct WorldPalette {
    public let dark: Bool
    public let tone: WorldTone
    public init(_ tone: WorldTone, _ scheme: ColorScheme) { self.tone = tone; dark = scheme == .dark }
    public var paper: Color { dark ? hex(tone == .morning ? 0x172637 : 0x152D2C) : hex(tone == .morning ? 0xEDF2F7 : 0xEDF3EB) }
    public var wall: Color { dark ? hex(tone == .morning ? 0x283B53 : 0x274442) : hex(tone == .morning ? 0xD6E4F2 : 0xD5E6DA) }
    public var ink: Color { dark ? hex(0xF6EEE2) : hex(0x243C4A) }
    public var secondary: Color { dark ? hex(0xC0CFD4) : hex(0x4B626C) }
    public var floorSecondary: Color { dark ? secondary : hex(0x3F535B) }
    public var accent: Color { dark ? hex(tone == .morning ? 0xA8CAF5 : 0xA3D9BD) : hex(tone == .morning ? 0x345C8D : 0x28614F) }
    public var action: Color { hex(tone == .morning ? 0x345C8D : 0x28614F) }
    public var floor: Color { dark ? hex(0x35404A) : hex(0xDAC5AB) }
    public var wood: Color { dark ? hex(0x99775D) : hex(0xB88D67) }
    public var woodEdge: Color { dark ? hex(0x664F40) : hex(0x845C43) }
    public var cream: Color { dark ? hex(0xD4CAB8) : hex(0xFFF3DA) }
    public var cloth: Color { hex(tone == .morning ? (dark ? 0x688BBC : 0x83ABDC) : (dark ? 0x659A87 : 0x94B9A0)) }
    public var leaf: Color { hex(dark ? 0x8DAE8C : 0x527C62) }
    public var gold: Color { hex(0xE8B76B) }
    public var shadow: Color { hex(0x172835).opacity(dark ? 0.3 : 0.13) }
}

public func hex(_ value: UInt32) -> Color {
    Color(red: Double((value >> 16) & 255) / 255, green: Double((value >> 8) & 255) / 255, blue: Double(value & 255) / 255)
}

public enum WorldType {
    public static let hero = Font.system(.largeTitle, design: .rounded).weight(.bold)
    public static let title = Font.system(.title2, design: .rounded).weight(.bold)
    public static let metric = Font.system(.largeTitle, design: .rounded).weight(.bold)
    public static let action = Font.system(.headline, design: .rounded)
}

/// Small drawing vocabulary. Coordinates belong to each product's artboard.
public struct Illustration {
    public var context: GraphicsContext
    public init(_ context: GraphicsContext) { self.context = context }
    public func shape(_ points: [CGPoint], _ color: Color) {
        guard let first = points.first else { return }
        var p = Path(); p.move(to: first); points.dropFirst().forEach { p.addLine(to: $0) }; p.closeSubpath()
        context.fill(p, with: .color(color))
    }
    public func polygon(_ xy: [CGFloat], _ color: Color) {
        shape(stride(from: 0, to: xy.count - 1, by: 2).map { CGPoint(x: xy[$0], y: xy[$0 + 1]) }, color)
    }
    public func round(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ radius: CGFloat, _ color: Color) {
        context.fill(Path(roundedRect: CGRect(x: x, y: y, width: w, height: h), cornerRadius: radius), with: .color(color))
    }
    public func oval(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ color: Color) {
        context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: w, height: h)), with: .color(color))
    }
    public func line(_ xy: [CGFloat], _ color: Color, _ width: CGFloat = 2) {
        guard xy.count >= 4 else { return }
        var p = Path(); p.move(to: CGPoint(x: xy[0], y: xy[1]))
        for i in stride(from: 2, to: xy.count - 1, by: 2) { p.addLine(to: CGPoint(x: xy[i], y: xy[i + 1])) }
        context.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
    }
    public func leaf(_ x: CGFloat, _ y: CGFloat, _ dx: CGFloat, _ dy: CGFloat, _ color: Color) {
        var p = Path(); p.move(to: CGPoint(x: x, y: y))
        p.addQuadCurve(to: CGPoint(x: x + dx, y: y + dy), control: CGPoint(x: x + dx, y: y))
        p.addQuadCurve(to: CGPoint(x: x, y: y), control: CGPoint(x: x, y: y + dy))
        context.fill(p, with: .color(color))
        line([x,y,x + dx * 0.78,y + dy * 0.78], .white.opacity(0.2), 1)
    }
    public func plant(_ x: CGFloat, _ y: CGFloat, _ scale: CGFloat, _ palette: WorldPalette) {
        var c = context; c.translateBy(x: x, y: y); c.scaleBy(x: scale, y: scale)
        let a = Illustration(c)
        a.oval(-30, 4, 60, 13, palette.shadow)
        a.line([0,0,0,-82], palette.leaf, 3)
        a.leaf(0,-20,-30,-23,palette.leaf); a.leaf(0,-38,33,-26,palette.leaf)
        a.leaf(0,-58,-25,-23,palette.leaf); a.leaf(0,-73,13,-30,palette.leaf)
        a.polygon([-25,-20,25,-20,19,12,-18,12], hex(0xC98261))
        a.oval(-25,-25,50,10,hex(0xE4AB82)); a.oval(-20,-23,40,6,palette.woodEdge)
        a.line([-15,-12,-11,7],.white.opacity(0.3),3)
    }
    public func books(_ x: CGFloat, _ y: CGFloat, _ palette: WorldPalette) {
        round(x,y,53,9,2,palette.cloth); round(x + 5,y - 9,48,8,2,palette.cream)
        line([x + 12,y - 5,x + 46,y - 5],palette.wood,1)
        round(x - 3,y - 17,48,7,2,hex(0xC98261))
    }
    public func lamp(_ x: CGFloat, _ y: CGFloat, _ palette: WorldPalette) {
        oval(x - 25,y - 5,50,9,palette.woodEdge)
        line([x,y - 6,x,y - 52],palette.gold,5)
        polygon([x - 18,y - 84,x + 18,y - 84,x + 31,y - 48,x - 31,y - 48],palette.cream)
        oval(x - 31,y - 53,62,10,palette.gold)
        line([x - 10,y - 77,x - 17,y - 55],.white.opacity(0.5),2)
    }
}

private struct CompanionMotion { var lift: Double = 0; var turn: Double = 0 }

public enum CompanionMood: Equatable, Sendable {
    case sleepy, curious, idle, waking, happy, celebration, calm, helping, proud
}

/// Original Mochi: folded tuft, scarf, cream mask, feet and articulated mitten arms.
public struct CompanionView: View {
    public let mood: CompanionMood
    public let accent: Color
    public var active: Bool
    @Environment(\.scenePhase) private var phase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var visible = false
    @State private var blink = false
    @State private var look: CGFloat = 0
    @State private var stretch = false
    public init(mood: CompanionMood = .idle, accent: Color = .accentColor, active: Bool = true) {
        self.mood = mood; self.accent = accent; self.active = active
    }
    private var running: Bool { active && visible && phase == .active && !reduceMotion }
    public var body: some View {
        Canvas { context, size in
            var c = context
            let s = min(size.width / 150, size.height / 160)
            c.translateBy(x: (size.width - 150 * s) / 2, y: (size.height - 160 * s) / 2)
            c.scaleBy(x: s, y: s)
            let a = Illustration(c)
            let blue = hex(0x739ACA), edge = hex(0x42638D), face = hex(0xFFF0D9), ink = hex(0x293D50)
            a.oval(29,143,96,12,.black.opacity(0.15))
            a.oval(36,128,31,21,edge); a.oval(83,128,31,21,edge)
            var body = Path()
            body.move(to: CGPoint(x: 36, y: 54))
            body.addCurve(to: CGPoint(x: 56, y: 25), control1: CGPoint(x: 33,y: 34), control2: CGPoint(x: 49,y: 34))
            body.addQuadCurve(to: CGPoint(x: 64,y: 9), control: CGPoint(x: 51,y: 5))
            body.addQuadCurve(to: CGPoint(x: 86,y: 24), control: CGPoint(x: 81,y: 8))
            body.addCurve(to: CGPoint(x: 119,y: 62), control1: CGPoint(x: 119,y: 22), control2: CGPoint(x: 124,y: 46))
            body.addCurve(to: CGPoint(x: 123,y: 126), control1: CGPoint(x: 128,y: 83), control2: CGPoint(x: 136,y: 111))
            body.addCurve(to: CGPoint(x: 29,y: 126), control1: CGPoint(x: 110,y: 149), control2: CGPoint(x: 46,y: 152))
            body.addCurve(to: CGPoint(x: 36,y: 54), control1: CGPoint(x: 11,y: 108), control2: CGPoint(x: 28,y: 74))
            c.fill(body, with: .linearGradient(Gradient(colors: [hex(0xAECDE9),blue,edge]), startPoint: CGPoint(x: 30,y: 20), endPoint: CGPoint(x: 122,y: 160)))
            a.leaf(59,25,19,5,hex(0xD2E3EF))
            a.oval(37,43,77,62,face)
            a.oval(41,77,15,8,hex(0xE9A28F).opacity(0.7)); a.oval(96,77,15,8,hex(0xE9A28F).opacity(0.7))
            let closed = blink || mood == .sleepy || mood == .calm
            for x: CGFloat in [58,88] {
                if closed { a.line([x - 4,66,x,69,x + 4,66],ink,3) }
                else {
                    a.oval(x - 4 + look,60,9,13,ink)
                    a.oval(x - 1 + look,62,3,4,.white)
                }
            }
            if mood == .celebration || mood == .happy {
                a.oval(68,79,15,11,ink); a.oval(71,84,9,5,hex(0xDB8D80))
            } else { a.line([69,81,75,84,81,81],ink,2) }
            a.polygon([38,99,76,107,115,98,104,115,48,116],hex(0xD88F63))
            a.polygon([76,110,98,114,91,134,77,126],hex(0xE4AB77))
            a.line([83,116,87,125],face.opacity(0.7),1.5)
            // The arms carry the action: reach, stretch, wave or rest.
            let reach = mood == .helping
            let raised = mood == .celebration || mood == .waking || stretch
            a.oval(reach ? 2 : 17, raised ? 49 : 92, 26, raised ? 46 : 33,blue)
            a.oval(reach ? 112 : 109, raised ? 43 : 94, 27, raised ? 48 : 31,blue)
            a.line([26,raised ? 58 : 101,29,raised ? 69 : 112],.white.opacity(0.25),3)
            if mood == .helping {
                a.round(108,112,34,16,4,hex(0xEBC58A))
                a.line([114,119,137,119],face,2)
            }
        }
        .aspectRatio(150.0 / 160.0, contentMode: .fit)
        .rotationEffect(.degrees(reduceMotion ? 0 : mood == .curious ? -7 : mood == .sleepy ? 5 : stretch ? -3 : 0))
        .offset(y: reduceMotion ? 0 : mood == .celebration ? -9 : 0)
        .keyframeAnimator(initialValue: CompanionMotion(), trigger: mood) { [reduceMotion, active] view, motion in
            view.offset(y: reduceMotion || !active ? 0 : motion.lift)
                .rotationEffect(.degrees(reduceMotion || !active ? 0 : motion.turn))
        } keyframes: { _ in
            KeyframeTrack(\.lift) {
                CubicKeyframe(mood == .celebration ? -15 : mood == .waking ? -5 : 0, duration: 0.22)
                SpringKeyframe(0, duration: 0.5, spring: .smooth)
            }
            KeyframeTrack(\.turn) {
                CubicKeyframe(mood == .curious ? 6 : mood == .proud ? -4 : 0, duration: 0.2)
                SpringKeyframe(0, duration: 0.5, spring: .smooth)
            }
        }
        .animation(reduceMotion ? nil : .spring(response: 0.6), value: stretch)
        .onAppear { visible = true }
        .onDisappear { visible = false }
        .task(id: "\(running)-\(mood)") {
            guard running else { blink = false; stretch = false; look = 0; return }
            var beat = 0
            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .seconds(Double.random(in: 3.8...7.8)))
                    guard mood != .celebration && mood != .helping else { continue }
                    beat += 1
                    if beat % 3 == 0 {
                        withAnimation(.spring(response: 0.6)) { look = beat % 2 == 0 ? -3 : 3; stretch = true }
                        try await Task.sleep(for: .milliseconds(700))
                        withAnimation { look = 0; stretch = false }
                    } else {
                        blink = true
                        try await Task.sleep(for: .milliseconds(130))
                        blink = false
                    }
                } catch { blink = false; look = 0; stretch = false; return }
            }
        }
        .accessibilityLabel("Mochi, your companion")
    }
}


/// Deterministic visual QA overrides. Release builds always follow system settings.
public struct WorldPreviewConfiguration: ViewModifier {
    public init() {}
    public func body(content: Content) -> some View {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        let scheme: ColorScheme? = args.contains("-qa-dark") ? .dark : args.contains("-qa-light") ? .light : nil
        if args.contains("-qa-large-text") {
            content.preferredColorScheme(scheme).dynamicTypeSize(.accessibility3)
        } else { content.preferredColorScheme(scheme) }
        #else
        content
        #endif
    }
}

/// Continues the artboard's floor under supporting copy and earned objects.
/// The endpoints meet the existing illustration; there is no separate footer surface.
public struct WorldForeground: View {
    public let palette: WorldPalette
    public let sceneHeight: CGFloat
    public init(palette: WorldPalette, sceneHeight: CGFloat) {
        self.palette = palette; self.sceneHeight = sceneHeight
    }
    public var body: some View {
        Canvas { context, size in
            let morning = palette.tone == .morning
            let start = morning ? -200 : -80
            let end = morning ? 650 : 480
            let step = morning ? 74 : 75
            let horizon: CGFloat = morning ? 263 : 320
            for x in stride(from: start, through: end, by: step) {
                let edge = CGFloat(x) * size.width / 400
                let upper = (CGFloat(x) * (morning ? 0.7 : 0.8) + (morning ? 70 : 40)) * size.width / 400
                let slope = (edge - upper) / max(1, sceneHeight * (440 - horizon) / 440)
                var line = Path()
                line.move(to: CGPoint(x: edge, y: 0))
                line.addLine(to: CGPoint(x: edge + slope * size.height, y: size.height))
                context.stroke(line, with: .color(palette.woodEdge.opacity(morning ? 0.17 : 0.15)), lineWidth: size.width / 400)
            }
        }.background(palette.floor).accessibilityHidden(true).allowsHitTesting(false)
    }
}
