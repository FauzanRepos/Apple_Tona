//
//  TonaButton.swift
//  Tona
//
//  Created by Apple Dev on 06/09/25.
//

import SwiftUI

enum TonaButtonStyle {
    case primary
    case secondary
}

struct TonaButton: View {
    let title: String
    let style: TonaButtonStyle
    let action: () -> Void
    let isEnabled: Bool
    
    init(
        _ title: String,
        style: TonaButtonStyle = .primary,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.tonaButtonText())
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: TonaBorderRadius.buttons)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
                .cornerRadius(TonaBorderRadius.buttons)
        }
        .disabled(!isEnabled)
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.1), value: isEnabled)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return isEnabled ? TonaColors.primaryBlue : TonaColors.mediumGray
        case .secondary:
            return Color.clear
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary:
            return TonaColors.white
        case .secondary:
            return TonaColors.primaryBlue
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary:
            return Color.clear
        case .secondary:
            return TonaColors.mediumGray
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .primary:
            return 0
        case .secondary:
            return 1
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        TonaButton("Primary Button", style: .primary) {
            print("Primary tapped")
        }
        
        TonaButton("Secondary Button", style: .secondary) {
            print("Secondary tapped")
        }
        
        TonaButton("Disabled Button", style: .primary, isEnabled: false) {
            print("Disabled tapped")
        }
    }
    .padding()
}
