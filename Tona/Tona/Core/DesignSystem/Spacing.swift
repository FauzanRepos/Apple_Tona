//
//  Spacing.swift
//  Tona
//
//  Created by Apple Dev on 06/09/25.
//

import SwiftUI

struct TonaSpacing {
    // MARK: - Base Unit (8px)
    static let baseUnit: CGFloat = 8
    
    // MARK: - Spacing Scale
    static let xs: CGFloat = 4    // 4px
    static let sm: CGFloat = 8    // 8px
    static let md: CGFloat = 16   // 16px
    static let lg: CGFloat = 24   // 24px
    static let xl: CGFloat = 32   // 32px
    static let xxl: CGFloat = 48  // 48px
    
    // MARK: - Layout Spacing
    static let screenMargins: CGFloat = 20
    static let cardPadding: CGFloat = 16
    static let buttonPadding: CGFloat = 12
    static let buttonHorizontalPadding: CGFloat = 24
}

// MARK: - Spacing Extensions
extension CGFloat {
    static let tonaXS = TonaSpacing.xs
    static let tonaSM = TonaSpacing.sm
    static let tonaMD = TonaSpacing.md
    static let tonaLG = TonaSpacing.lg
    static let tonaXL = TonaSpacing.xl
    static let tonaXXL = TonaSpacing.xxl
    static let tonaScreenMargins = TonaSpacing.screenMargins
    static let tonaCardPadding = TonaSpacing.cardPadding
}
