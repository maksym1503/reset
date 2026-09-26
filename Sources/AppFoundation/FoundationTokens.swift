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
    public static let primary = Color.accentColor
    public static let muted = Color.secondary
}

public struct FoundationCard<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content.padding(20).background(FoundationTokens.surface, in: RoundedRectangle(cornerRadius: 24))
    }
}
