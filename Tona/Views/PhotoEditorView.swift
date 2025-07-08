//
//  PhotoEditorView.swift
//  Tona
//
//  Created by Apple Dev on 08/07/25.
//

import SwiftUI
import PhotosUI

struct PhotoEditorView: View {
    let toneStyle: ToneStyle
    var onAdjust: ((UIImage) -> Void)? = nil
    @StateObject private var viewModel = PhotoEditorViewModel()
    @State private var showLoading = false
    @State private var selectedImage: UIImage? = nil
    @State private var processedImage: UIImage? = nil
    @State private var showShareSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar title and back handled by parent
            Spacer().frame(height: 16)
            
            // Main content
            if selectedImage == nil {
                // Empty state: Large square upload area
                Button(action: { viewModel.showPhotoPicker = true }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.systemGray5))
                            .frame(width: 280, height: 280)
                            .shadow(radius: 2)
                        VStack(spacing: 16) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 56, height: 56)
                                .foregroundColor(Color.tonaAccentBlue)
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(Color.tonaAccentBlue)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .photosPicker(isPresented: $viewModel.showPhotoPicker, selection: $viewModel.selectedItems, matching: .images)
                .onChange(of: viewModel.selectedItems) { _, _ in
                    viewModel.loadSelectedImages { images in
                        if let img = images.first {
                            selectedImage = img
                            processedImage = nil
                        }
                    }
                }
                Spacer().frame(height: 32)
            } else {
                // Editing state: Two side-by-side images
                HStack(alignment: .top, spacing: 12) {
                    if let original = selectedImage {
                        Image(uiImage: original)
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .frame(width: 160, height: 200)
                            .clipped()
                            .cornerRadius(12)
                    }
                    ZStack(alignment: .topTrailing) {
                        if let edited = processedImage ?? selectedImage {
                            Image(uiImage: edited)
                                .resizable()
                                .aspectRatio(1, contentMode: .fill)
                                .frame(width: 160, height: 200)
                                .clipped()
                                .cornerRadius(12)
                        }
                        // X button to remove/reset
                        Button(action: {
                            selectedImage = nil
                            processedImage = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.blue)
                                .background(Color.white)
                                .clipShape(Circle())
                                .padding(6)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
                .padding(.bottom, 4)
                
                // Tap to adjust
                Button(action: { 
                    if let img = processedImage ?? selectedImage {
                        onAdjust?(img)
                    }
                }) {
                    Text("tap to adjust")
                        .font(.subheadline)
                        .foregroundColor(Color.tonaDeepBlue.opacity(0.7))
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                }
                
                // Save/Share buttons
                HStack(spacing: 16) {
                    Button("Save to Photos") {
                        if let img = processedImage ?? selectedImage {
                            PhotoProcessingService.shared.saveImageToPhotos(img)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 18)
                    .background(Color.green.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Share") {
                        showShareSheet = true
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 18)
                    .background(Color.purple.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .sheet(isPresented: $showShareSheet) {
                        if let img = processedImage ?? selectedImage {
                            ShareSheet(activityItems: [img])
                        }
                    }
                }
                .padding(.bottom, 8)
            }
            Spacer()
            // Tone cards at the bottom
            ToneCardGallery(selectedTone: toneStyle)
                .padding(.bottom, 12)
        }
        .padding(.horizontal, 0)
        .background(Color.tonaOffWhite.ignoresSafeArea())
        .navigationTitle("Upload Photo")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Helper for tone cards at the bottom
struct ToneCardGallery: View {
    let selectedTone: ToneStyle
    // This should be replaced with your actual tone list
    let tones: [ToneStyle] = [
        // ToneStyle(name: "Sunrises", previewImageData: nil),
        // ToneStyle(name: "Pinkies", previewImageData: nil),
        // ToneStyle(name: "Moody", previewImageData: nil)
    ]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(tones, id: \.id) { tone in
                    ZStack(alignment: .bottomLeading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 110, height: 150)
                            .cornerRadius(16)
                        Text(tone.name)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(tone.id == selectedTone.id ? Color.tonaAccentBlue.opacity(0.7) : Color.black.opacity(0.4))
                            .cornerRadius(8)
                            .padding([.leading, .bottom], 8)
                    }
                }
            }
            .padding(.horizontal, 12)
        }
    }
}
