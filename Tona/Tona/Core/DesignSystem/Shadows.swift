//
//  Shadows.swift
//  Tona
//
//  Created by Apple Dev on 06/09/25.
//

import SwiftUI

struct TonaShadows {
    // MARK: - Shadow Values
    static let light = Color.black.opacity(0.1)
    static let medium = Color.black.opacity(0.15)
    
    // MARK: - Shadow Configurations
    static let lightShadow = Shadow(
        color: light,
        radius: 4,
        x: 0,
        y: 2
    )
    
    static let mediumShadow = Shadow(
        color: medium,
        radius: 8,
        x: 0,
        y: 4
    )
}

// MARK: - Shadow Structure
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extension for Shadows
extension View {
    func tonaLightShadow() -> some View {
        self.shadow(
            color: TonaShadows.light,
            radius: 4,
            x: 0,
            y: 2
        )
    }
    
    func tonaMediumShadow() -> some View {
        self.shadow(
            color: TonaShadows.medium,
            radius: 8,
            x: 0,
            y: 4
        )
    }
}
