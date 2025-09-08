//
//  PhotoCard.swift
//  Tona
//
//  Created by Apple Dev on 06/09/25.
//

import SwiftUI

struct PhotoCard: View {
    let image: Image?
    let isPlaceholder: Bool
    let onTap: (() -> Void)?
    
    init(
        image: Image? = nil,
        isPlaceholder: Bool = false,
        onTap: (() -> Void)? = nil
    ) {
        self.image = image
        self.isPlaceholder = isPlaceholder
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap ?? {}) {
            ZStack {
                RoundedRectangle(cornerRadius: TonaBorderRadius.cards)
                    .fill(TonaColors.white)
                    .aspectRatio(1, contentMode: .fit)
                    .tonaLightShadow()
                
                if isPlaceholder {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.stack")
                            .font(.system(size: 32, weight: .regular))
                            .foregroundColor(TonaColors.mediumGray)
                        
                        Text("Add Photo")
                            .font(.tonaCaption())
                            .foregroundColor(TonaColors.darkGray)
                    }
                } else if let image = image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .cornerRadius(TonaBorderRadius.cards)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(onTap == nil)
    }
}

#Preview {
    VStack(spacing: 20) {
        PhotoCard(isPlaceholder: true) {
            print("Placeholder tapped")
        }
        
        PhotoCard(
            image: Image(systemName: "photo"),
            isPlaceholder: false
        ) {
            print("Photo tapped")
        }
    }
    .padding()
}
