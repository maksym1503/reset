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
