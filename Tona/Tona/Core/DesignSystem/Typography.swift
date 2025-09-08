//
//  Typography.swift
//  Tona
//
//  Created by Apple Dev on 06/09/25.
//

import SwiftUI

struct TonaTypography {
    // MARK: - Font Sizes
    static let title1Size: CGFloat = 28
    static let title2Size: CGFloat = 22
    static let bodySize: CGFloat = 17
    static let captionSize: CGFloat = 15
    static let buttonTextSize: CGFloat = 17
    
    // MARK: - Line Heights
    static let title1LineHeight: CGFloat = 34
    static let title2LineHeight: CGFloat = 28
    static let bodyLineHeight: CGFloat = 22
    static let captionLineHeight: CGFloat = 20
    
    // MARK: - Font Weights
    static let bold = Font.Weight.bold
    static let semibold = Font.Weight.semibold
    static let regular = Font.Weight.regular
}

// MARK: - Typography Styles
extension Font {
    static func tonaTitle1() -> Font {
        return .system(size: TonaTypography.title1Size, weight: TonaTypography.bold)
    }
    
    static func tonaTitle2() -> Font {
        return .system(size: TonaTypography.title2Size, weight: TonaTypography.bold)
    }
    
    static func tonaBody() -> Font {
        return .system(size: TonaTypography.bodySize, weight: TonaTypography.regular)
    }
    
    static func tonaCaption() -> Font {
        return .system(size: TonaTypography.captionSize, weight: TonaTypography.regular)
    }
    
    static func tonaButtonText() -> Font {
        return .system(size: TonaTypography.buttonTextSize, weight: TonaTypography.semibold)
    }
}
