import SwiftUI

public enum FoundationTokens {
    public static var background: Color {
        #if os(iOS)
        Color(uiColor: .systemGroupedBackground)
        #else
        Color(nsColor: .windowBackgroundColor)
        #endif
    }
    public static var surface: Color {
        #if os(iOS)
        Color(uiColor: .secondarySystemGroupedBackground)
        #else
        Color(nsColor: .controlBackgroundColor)
        #endif
    }
    public static var primary: Color {
        #if os(iOS)
        Color(uiColor: .init { traits in
            traits.userInterfaceStyle == .dark
                ? .init(red: 0.48, green: 0.70, blue: 1, alpha: 1)
                : .init(red: 0.12, green: 0.30, blue: 0.67, alpha: 1)
        })
        #else
        Color.accentColor
        #endif
    }
    public static var muted: Color {
        #if os(iOS)
        Color(uiColor: .init { traits in
            .init(white: traits.userInterfaceStyle == .dark ? 0.76 : 0.36, alpha: 1)
        })
        #else
        Color(nsColor: .secondaryLabelColor)
        #endif
    }
    // Filled controls use a deeper color so white labels stay readable.
    public static let action = Color(red: 0.12, green: 0.30, blue: 0.67)
    public static let success = Color(red: 0.12, green: 0.43, blue: 0.29)
}

public struct FoundationCard<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(FoundationTokens.surface, in: RoundedRectangle(cornerRadius: 22))
            .overlay {
                RoundedRectangle(cornerRadius: 22)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
            }
    }
}

public enum CompanionMood: Equatable, Sendable { case sleepy, curious, idle, waking, happy, celebration, calm }

public struct CompanionView: View {
    public let mood: CompanionMood
    public let accent: Color
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var breathing = false
    @State private var blink = false
    public init(mood: CompanionMood = .idle, accent: Color = .accentColor) { self.mood = mood; self.accent = accent }
    public var body: some View {
        ZStack {
            Ellipse().fill(.black.opacity(0.12)).frame(width: 92, height: 18).offset(y: 47)
            VStack(spacing: 0) {
                HStack(spacing: 9) { Eye(closed: blink || mood == .sleepy); Eye(closed: blink || mood == .sleepy) }
                Mouth(mood: mood).stroke(.primary.opacity(0.8), style: StrokeStyle(lineWidth: 2.5, lineCap: .round)).frame(width: 22, height: 14).padding(.top, 7)
            }.frame(width: 96, height: 92)
                .background(LinearGradient(colors: [accent.opacity(0.95), accent.opacity(0.64)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 38, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 38, style: .continuous).stroke(.white.opacity(0.45), lineWidth: 2))
            HStack(spacing: 72) { Capsule().fill(accent.opacity(0.8)).frame(width: 15, height: 42).rotationEffect(.degrees(mood == .celebration ? -28 : 12)); Capsule().fill(accent.opacity(0.8)).frame(width: 15, height: 42).rotationEffect(.degrees(mood == .celebration ? 28 : -12)) }.offset(y: 8)
            if mood == .celebration || mood == .happy { Text("✦").font(.title2.bold()).foregroundStyle(.yellow).offset(x: 60, y: -55) }
        }.scaleEffect(breathing && !reduceMotion ? 1.035 : 1).rotationEffect(.degrees(mood == .celebration && !reduceMotion ? (breathing ? 2 : -2) : 0))
            .task(id: reduceMotion) {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) { breathing = true }
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(Double.random(in: 3.5...7.5)))
                    guard !Task.isCancelled else { return }
                    withAnimation(.easeInOut(duration: 0.09)) { blink = true }
                    try? await Task.sleep(for: .milliseconds(120))
                    withAnimation(.easeInOut(duration: 0.09)) { blink = false }
                }
            }
            .accessibilityLabel("Mochi, your companion")
    }
}
private struct Eye: View { let closed: Bool; var body: some View { Capsule().fill(.primary.opacity(0.8)).frame(width: 9, height: closed ? 2 : 11) } }
private struct Mouth: Shape { let mood: CompanionMood; func path(in rect: CGRect) -> Path { var p = Path(); let y = rect.midY; if mood == .happy || mood == .celebration { p.addArc(center: CGPoint(x: rect.midX, y: y - 2), radius: 8, startAngle: .degrees(20), endAngle: .degrees(160), clockwise: false) } else { p.move(to: CGPoint(x: rect.minX + 4, y: y)); p.addLine(to: CGPoint(x: rect.maxX - 4, y: y)) }; return p } }
