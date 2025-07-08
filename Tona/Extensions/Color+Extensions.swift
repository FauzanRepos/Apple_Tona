//
//  Color+Extensions.swift
//  Tona
//
//  Created by Apple Dev on 08/07/25.
//

import SwiftUI

extension Color {
    
    // MARK: - App Theme Colors
    
    static let appPrimary = Color.blue
    static let appSecondary = Color.purple
    static let appAccent = Color.orange
    static let appSuccess = Color.green
    static let appWarning = Color.yellow
    static let appError = Color.red
    
    // MARK: - App Theme Colors 
    static let tonaDeepBlue = Color("DeepBlue")
    static let tonaAccentBlue = Color("AccentColor")
    static let tonaOffWhite = Color("OffWhite")
    static let tonaCardShadow = Color.black.opacity(0.07)
    
    // MARK: - Tone Style Colors
    
    static let vintageWarm = Color.orange
    static let coolBlue = Color.blue
    static let highContrast = Color.purple
    static let warmFilter = Color.red
    static let coolFilter = Color.cyan
    
    // MARK: - Background Colors
    
    static let cardBackground = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)
    
    // MARK: - Text Colors
    
    static let primaryText = Color(.label)
    static let secondaryText = Color(.secondaryLabel)
    static let tertiaryText = Color(.tertiaryLabel)
    
    // MARK: - Utility Methods
    
    func withOpacity(_ opacity: Double) -> Color {
        return self.opacity(opacity)
    }
    
    func lighter(by amount: Double = 0.2) -> Color {
        return self.opacity(1.0 - amount)
    }
    
    func darker(by amount: Double = 0.2) -> Color {
        return self.opacity(1.0 + amount)
    }
}

extension Color {
    /// Initialize Color from hex string (e.g. "#223447")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Color Schemes

extension Color {
    static func adaptiveColor(light: Color, dark: Color) -> Color {
        return Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
    
    static let adaptiveBackground = adaptiveColor(
        light: Color(.systemBackground),
        dark: Color(.systemBackground)
    )
    
    static let adaptiveCardBackground = adaptiveColor(
        light: Color(.secondarySystemBackground),
        dark: Color(.tertiarySystemBackground)
    )
}

// MARK: - Gradient Presets

extension LinearGradient {
    static let appGradient = LinearGradient(
        colors: [Color.appPrimary, Color.appSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let warmGradient = LinearGradient(
        colors: [Color.orange, Color.red],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let coolGradient = LinearGradient(
        colors: [Color.blue, Color.cyan],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let vintageGradient = LinearGradient(
        colors: [Color.brown, Color.orange],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
} 