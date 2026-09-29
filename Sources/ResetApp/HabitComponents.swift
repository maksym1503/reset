import SwiftUI
import ResetFoundation

/// A desk in perspective: warm task light, cable routing, paper, ceramics and wood grain.
struct WorkspaceArtwork: View, Animatable {
    var progress: CGFloat
    let level: Int
    let palette: WorldPalette
    var animatableData: CGFloat { get { progress } set { progress = newValue } }
    var body: some View {
        Canvas { context, size in
            var c = context; c.scaleBy(x: size.width / 400, y: size.height / 440)
            drawWorkspace(Illustration(c))
        }.accessibilityHidden(true)
    }
    private func drawWorkspace(_ a: Illustration) {
        let p = palette
        a.round(0,0,400,440,0,p.wall)
        a.round(0,318,400,122,0,p.floor)
        a.line([0,318,400,318],p.cream.opacity(0.25),5)
        for x in stride(from: -80, through: 480, by: 75) {
            a.line([CGFloat(x),440,CGFloat(x) * 0.8 + 40,320],p.woodEdge.opacity(0.15),1)
        }
        // Window with evening hills and slatted shade.
        a.round(233,24,130,132,5,p.woodEdge)
        a.round(240,31,116,118,2,p.dark ? hex(0x3D6580) : hex(0xBBDDD9))
        a.oval(315,42,22,22,p.cream)
        a.polygon([240,133,269,97,306,120,332,88,356,111,356,149,240,149],p.dark ? hex(0x315668) : hex(0x7CAAA6))
        a.line([298,31,298,151],p.cream,4)
        for y in stride(from: 33, through: 57, by: 6) { a.round(237,CGFloat(y),122,4,1,p.wood) }
        a.line([361,49,361,120],p.cream,1); a.oval(358,119,6,9,p.cream)
        a.round(229,153,138,8,2,p.cream)
        // Pinned sketch and a real wall shelf.
        a.round(44,55,58,72,2,p.cream); a.oval(69,59,5,5,p.gold)
        a.line([72,117,72,76],p.leaf,1)
        a.leaf(72,107,-17,-14,p.leaf)
        a.leaf(72,95,17,-15,p.leaf)
        a.leaf(72,81,-10,-11,p.leaf)
        a.line([53,118,92,118],p.wood,1)
        a.round(34,169,119,8,2,p.wood)
        a.books(49,166,p)
        if level >= 3 {
            a.round(110,111,34,52,2,p.woodEdge); a.round(114,115,26,44,1,p.cream)
            a.oval(128,120,8,8,p.gold)
            a.polygon([116,155,125,132,136,155],p.cloth)
            a.polygon([123,156,135,138,140,156],p.leaf)
        }
        // Soft pool of light comes from the articulated desk lamp.
        a.polygon([65,202,112,200,260,321,18,323],p.gold.opacity(0.08 + 0.13 * progress))
        // Rug and desk legs are the lower foreground, not a blank footer.
        a.oval(44,359,322,64,p.shadow)
        a.oval(50,354,310, 60,p.dark ? hex(0x3C6158) : hex(0xA1B9A6))
        a.context.stroke(Path(ellipseIn: CGRect(x: 66,y: 362,width: 278,height: 46)),with: .color(p.cream.opacity(0.4)),lineWidth: 2)
        a.polygon([40,315,55,315,49,398,36,398],p.woodEdge)
        a.polygon([345,315,360,315,365,398,351,398],p.woodEdge)
        a.line([51,373,347,373],p.wood,5)
        // Desktop, front apron and drawer.
        a.polygon([55,259,346,259,389,321,14,321],p.wood)
        a.round(14,317,375,15,4,p.woodEdge)
        a.round(234,333,102,28,4,p.wood)
        a.line([272,343,300,343],p.woodEdge,3)
        a.line([65,268,337,268],p.cream.opacity(0.18),1)
        a.line([30,308,372,308],p.cream.opacity(0.18),1)
        // Articulated brass lamp.
        a.oval(42,287,57,11,p.woodEdge)
        a.line([72,287,59,231,100,195],p.gold,7)
        a.oval(53,226,13,13,p.woodEdge)
        a.polygon([89,182,117,186,126,208,81,206],p.cream)
        a.oval(80,203,48,9,p.gold)
        // Monitor on a stand, with a calm original horizon on the display.
        a.round(146,153,169,107,9,p.woodEdge)
        a.round(152,159,157,92,5,p.dark ? hex(0x234B58) : hex(0x92B8BE))
        a.oval(259,173,24,24,p.gold)
        a.polygon([152,242,184,204,219,224,255,191,309,231,309,251,152,251],p.dark ? hex(0x436D71) : hex(0x588790))
        a.polygon([152,244,196,233,229,241,309,216,309,251,152,251],p.leaf)
        a.round(221,260,14,18,2,p.woodEdge); a.oval(198,273,61,8,p.woodEdge)
        a.oval(225,254,4,4,p.gold)
        // Keyboard with real key rows and shadow.
        a.polygon([166,286,284,286,297,311,154,311],p.shadow)
        a.polygon([169,282,281,282,291,303,158,303],p.cream)
        for row in 0..<3 { for col in 0..<12 {
            a.round(168 + CGFloat(col)*9 - CGFloat(row)*2,286 + CGFloat(row)*5,6,3,1,p.wood.opacity(0.38))
        }}
        // Papers glide into a tidy notebook stack. Loose scraps leave the work surface.
        for i in 0..<3 {
            let t = CGFloat(i)
            let x = (90 + t * 59) * (1-progress) + 320 * progress
            let y = (288 + t * 8) * (1-progress) + (280 + t * 3) * progress
            var c = a.context; c.translateBy(x: x,y: y); c.rotate(by: .degrees(Double((1-progress) * (t - 1) * 18)))
            let page = Illustration(c)
            page.round(-25,-15,48,31,2,p.cream)
            page.line([-17,-6,13,-6],p.wood.opacity(0.45),1)
            page.line([-17,0,5,0],p.wood.opacity(0.35),1)
        }
        if progress > 0.65 { a.round(295,262,49,11,2,p.cloth) }
        // Cup moves out of the typing space; handle remains physically attached.
        let cx: CGFloat = 215 - progress * 93
        let cy: CGFloat = 310 - progress * 28
        a.context.stroke(Path(ellipseIn: CGRect(x: cx + 13,y: cy - 18,width: 17,height: 17)),with: .color(p.cream),lineWidth: 5)
        a.round(cx - 12,cy - 24,31,28,6,p.cream); a.oval(cx - 12,cy - 27,31,8,hex(0xD4B897))
        a.oval(cx - 8,cy - 25,23,4,p.woodEdge)
        // Pen settles parallel with the notebook.
        a.line([300 - 68*(1-progress),294 + 23*(1-progress),337 - 40*(1-progress),294 - 3*(1-progress)],p.action,3)
        if progress < 0.98 {
            for i in 0..<4 {
                let x = CGFloat(96 + i * 38) + progress * 170
                a.oval(x,307 + CGFloat(i % 2) * 7,3,2,p.woodEdge.opacity(1-progress))
            }
        }
        if level >= 2 { a.plant(352,273,0.58,p) }
        if level >= 4 {
            a.round(22,217,99,7,2,p.wood)
            a.books(31,208,p)
            a.books(43,190,p)
        }
        if level >= 5 {
            a.round(295,271,50,28,3,p.action)
            a.round(300,274,42,22,2,p.cream)
            a.line([331,273,331,297],p.gold,2)
        }
        if level >= 7 {
            a.round(254,144,84,13,3,p.wood)
            for x: CGFloat in [267,295,323] {
                a.line([x,145,x,122],p.leaf,2)
                a.leaf(x,138,-10,-12,p.leaf); a.leaf(x,131,10,-12,p.leaf)
                a.oval(x-4,117,8,8,p.gold)
            }
        }
        // Canvas tote beneath the desk explains the otherwise empty foreground.
        a.round(271,373,51,48,8,p.cream)
        a.context.stroke(Path(roundedRect: CGRect(x: 282,y: 359,width: 27,height: 28),cornerRadius: 10),with: .color(p.cream),lineWidth: 5)
        a.leaf(282,397,22,-10,p.leaf)
    }
}
struct DeskScene: View {
    let level: Int
    let clean: Bool
    @Environment(\.colorScheme) private var scheme
    var body: some View {
        WorkspaceArtwork(progress: clean ? 1 : 0, level: level, palette: WorldPalette(.focus, scheme))
            .aspectRatio(400/440, contentMode: .fit)
    }
}
