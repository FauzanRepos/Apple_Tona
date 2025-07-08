//
//  ToneCollectionView.swift
//  Tona
//
//  Created by Apple Dev on 08/07/25.
//

import SwiftUI

struct ToneCollectionView: View {
    @StateObject private var viewModel = ToneCollectionViewModel()
    var onAddTone: (() -> Void)? = nil
    var onSelectTone: ((ToneStyle) -> Void)? = nil
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.tonaOffWhite.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                // Header (Figma style)
                HStack(alignment: .center) {
                    Text("Tone Collection")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color.tonaDeepBlue)
                    Spacer()
                    Button(action: { onAddTone?() }) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(Color.tonaAccentBlue)
                    }
                    .accessibilityLabel("Add Tone")
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
                
                if viewModel.toneStyles.isEmpty {
                    // Placeholder for empty state
                    VStack(spacing: 24) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .foregroundColor(Color.tonaDeepBlue.opacity(0.18))
                        Text("Welcome to Tona")
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.tonaDeepBlue)
                        Text("Create and collect your own photo tone styles. Upload reference images, analyze their tonality, and apply unique looks to your photos using AI. Start by adding your first tone style.")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color.tonaDeepBlue.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 18)
                        Button(action: { onAddTone?() }) {
                            Text("Add Your First Tone")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 40)
                                .background(Color.tonaDeepBlue)
                                .clipShape(Capsule())
                                .shadow(color: Color.tonaDeepBlue.opacity(0.18), radius: 8, y: 4)
                        }
                        .accessibilityLabel("Add Your First Tone")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 60)
                } else {
                    // Card List
                    ScrollView {
                        VStack(spacing: 28) {
                            ForEach(viewModel.toneStyles, id: \.id) { toneStyle in
                                ToneGalleryCard(toneStyle: toneStyle) {
                                    onSelectTone?(toneStyle)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 80)
                    }
                }
            }
        }
    }
}

struct ToneGalleryCard: View {
    let toneStyle: ToneStyle
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                if let previewData = toneStyle.previewImageData,
                   let previewImage = UIImage(data: previewData) {
                    Image(uiImage: previewImage)
                        .resizable()
                        .aspectRatio(1.2, contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.tonaOffWhite)
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 36))
                                .foregroundColor(Color.tonaDeepBlue.opacity(0.18))
                        )
                }
                // Glass effect label bar at the bottom of the image (reverted to previous opacity style)
                VStack(spacing: 0) {
                    Spacer()
                    ZStack {
                        BlurView(style: .systemUltraThinMaterialDark)
                            .frame(height: 48)
                            .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
                            .opacity(0.55)
                        Text(toneStyle.name)
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.35), radius: 4, x: 0, y: 2)
                            .padding(.horizontal, 18)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 200, alignment: .bottom)
            }
            .frame(maxWidth: .infinity)
            .background(Color.tonaOffWhite)
            .cornerRadius(16)
            .shadow(color: Color.tonaCardShadow, radius: 8, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// UIKit blur wrapper for SwiftUI
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// Helper for corner radius on specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 0.0
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// Sheet for creating a new tone
struct ToneCreationSheet: View {
    var onToneCreated: (ToneStyle) -> Void
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ToneCreationViewModel()
    @State private var isGenerating = false
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            ToneCreationView(
                onToneCreated: { newTone in
                    onToneCreated(newTone)
                    dismiss()
                },
                isGenerating: $isGenerating,
                showError: $showError
            )
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Collection")
                        }
                        .foregroundColor(Color.tonaAccentBlue)
                    }
                }
            }
        }
    }
}

// MARK: - Mock Data Example (JSON)
/*
[
  {
    "id": "A1B2C3D4-E5F6-7890-1234-56789ABCDEF0",
    "name": "Sunrises",
    "previewImageURL": "https://images.unsplash.com/photo-1.jpg",
    "createdAt": "2024-06-01T09:00:00Z"
  },
  {
    "id": "B2C3D4E5-F6A1-8901-2345-6789ABCDEF01",
    "name": "Pinkies",
    "previewImageURL": "https://images.unsplash.com/photo-2.jpg",
    "createdAt": "2024-06-02T10:00:00Z"
  }
]
*/

import SwiftUI

struct AddReferenceView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.tonaOffWhite.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 32) {
                    Text("Match your tone preference!")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundColor(Color.tonaAccentBlue)
                        .padding(.top, 16)
                        .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.tonaOffWhite)
                                .frame(width: 320, height: 320)
                                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                            
                            Button(action: {
                                // Handle image picker
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.tonaAccentBlue)
                                        .frame(width: 96, height: 96)
                                    Image(systemName: "photo.on.rectangle.angled") // Replace with your custom icon if needed
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 44, height: 44)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Collection")
                    }
                    .foregroundColor(Color.tonaAccentBlue)
                }
            }
        }
    }
}
