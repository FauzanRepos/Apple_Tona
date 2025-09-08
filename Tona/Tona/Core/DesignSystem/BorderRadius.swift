//
//  BorderRadius.swift
//  Tona
//
//  Created by Apple Dev on 06/09/25.
//

import SwiftUI

struct TonaBorderRadius {
    // MARK: - Border Radius Values
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let circular: CGFloat = 50
    
    // MARK: - Usage Guidelines
    static let cards = medium
    static let buttons = medium
    static let images = medium
    static let containers = large
}

// MARK: - Border Radius Extensions
extension CGFloat {
    static let tonaSmall = TonaBorderRadius.small
    static let tonaMedium = TonaBorderRadius.medium
    static let tonaLarge = TonaBorderRadius.large
    static let tonaCircular = TonaBorderRadius.circular
}
