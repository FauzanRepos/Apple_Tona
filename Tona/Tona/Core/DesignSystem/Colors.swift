//
//  Colors.swift
//  Tona
//
//  Created by Apple Dev on 06/09/25.
//

import SwiftUI

struct TonaColors {
    // MARK: - Primary Colors
    static let primaryBlue = Color(hex: "#007AFF")
    static let primaryDarkBlue = Color(hex: "#1E3A5F")
    
    // MARK: - Neutral Colors
    static let lightGray = Color(hex: "#F5F5F5")
    static let mediumGray = Color(hex: "#D1D1D6")
    static let darkGray = Color(hex: "#8E8E93")
    static let white = Color(hex: "#FFFFFF")
    
    // MARK: - Semantic Colors
    static let success = Color(hex: "#34C759")
    static let warning = Color(hex: "#FF9500")
    static let error = Color(hex: "#FF3B30")
}

// MARK: - Color Extension
extension Color {
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
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
