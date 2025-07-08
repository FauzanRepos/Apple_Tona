import SwiftUI

extension Font {
    static func onest(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        // The variable font supports a range of weights, so we map Font.Weight to the appropriate value
        let fontName = "Onest-VariableFont_wght"
        return .custom(fontName, size: size, relativeTo: .body).weight(weight)
    }
} 