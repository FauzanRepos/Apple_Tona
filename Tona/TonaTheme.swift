import SwiftUI

struct TonaTheme {
    // MARK: - Colors
    static let primaryColor = Color.tonaDeepBlue
    static let secondaryColor = Color.tonaAccentBlue
    static let accentColor = Color.appAccent
    static let backgroundColor = Color.tonaOffWhite
    static let cardShadowColor = Color.tonaCardShadow
    static let dangerColor = Color.red

    // MARK: - Fonts
    static func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return Font.onest(size: size, weight: weight)
    }

    // MARK: - Spacing
    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 16
    static let paddingLarge: CGFloat = 24
}
