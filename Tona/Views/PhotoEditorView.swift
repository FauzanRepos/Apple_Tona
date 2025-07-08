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
    @StateObject private var viewModel = PhotoEditorViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Image Display
                if let img = viewModel.processedImage ?? viewModel.originalImage {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No image selected")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Pick a photo to start editing")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Photo Picker
                PhotosPicker(
                    selection: $viewModel.selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Pick Photo to Edit")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .onChange(of: viewModel.selectedItem) { _, _ in
                    viewModel.loadSelectedImage()
                }
                
                // Tone Style Selection
                if viewModel.originalImage != nil {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Apply Tone Style")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ToneStyleButton(
                                    name: "Vintage Warm",
                                    color: .orange
                                ) {
                                    // Apply vintage filter
                                    if let original = viewModel.originalImage {
                                        viewModel.processedImage = original.applyingSepia(intensity: 0.8)?
                                            .applyingVignette(intensity: 0.5, radius: 1.0)
                                    }
                                }
                                
                                ToneStyleButton(
                                    name: "Cool Blue",
                                    color: .blue
                                ) {
                                    // Apply cool filter
                                    if let original = viewModel.originalImage {
                                        viewModel.processedImage = original.applyingTemperature(4000, tint: -0.1)?
                                            .applyingSaturation(0.8)
                                    }
                                }
                                
                                ToneStyleButton(
                                    name: "High Contrast",
                                    color: .purple
                                ) {
                                    // Apply high contrast filter
                                    if let original = viewModel.originalImage {
                                        viewModel.processedImage = original.applyingContrast(1.5)?
                                            .applyingSaturation(1.2)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Action Buttons
                if viewModel.processedImage != nil || viewModel.originalImage != nil {
                    VStack(spacing: 12) {
                        if viewModel.isProcessing {
                            ProgressView("Processing...")
                                .padding()
                        } else {
                            Button("Manual Edit") {
                                viewModel.showManualEdit = true
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            
                            HStack(spacing: 12) {
                                Button("Save to Photos") {
                                    viewModel.saveProcessedImage()
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                
                                Button("Share") {
                                    viewModel.shareProcessedImage()
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.orange.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            
                            Button("Reset") {
                                viewModel.resetToOriginal()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Edit Photo")
        .background(
            NavigationLink(
                destination: ManualEditView(inputImage: viewModel.processedImage ?? viewModel.originalImage ?? UIImage()),
                isActive: $viewModel.showManualEdit
            ) {
                EmptyView()
            }
        )
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

struct ToneStyleButton: View {
    let name: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Circle()
                    .fill(color.opacity(0.8))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "wand.and.stars")
                            .foregroundColor(.white)
                    )
                
                Text(name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
