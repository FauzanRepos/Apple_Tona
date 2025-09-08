//
//  UploadArea.swift
//  Tona
//
//  Created by Apple Dev on 06/09/25.
//

import SwiftUI

struct UploadArea: View {
    let title: String
    let subtitle: String
    let isDragOver: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 32, weight: .regular))
                    .foregroundColor(iconColor)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.tonaBody())
                        .foregroundColor(TonaColors.darkGray)
                    
                    Text(subtitle)
                        .font(.tonaCaption())
                        .foregroundColor(TonaColors.mediumGray)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 120)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: TonaBorderRadius.medium)
                    .stroke(borderColor, style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
            )
            .cornerRadius(TonaBorderRadius.medium)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isDragOver ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isDragOver)
    }
    
    private var backgroundColor: Color {
        isDragOver ? Color(hex: "#F0F8FF") : TonaColors.lightGray
    }
    
    private var borderColor: Color {
        isDragOver ? TonaColors.primaryBlue : TonaColors.mediumGray
    }
    
    private var iconColor: Color {
        isDragOver ? TonaColors.primaryBlue : TonaColors.mediumGray
    }
}

#Preview {
    VStack(spacing: 20) {
        UploadArea(
            title: "Upload First Group",
            subtitle: "Tap to select photos",
            isDragOver: false
        ) {
            print("Upload tapped")
        }
        
        UploadArea(
            title: "Upload Second Group",
            subtitle: "Tap to select photos",
            isDragOver: true
        ) {
            print("Upload tapped")
        }
    }
    .padding()
}
