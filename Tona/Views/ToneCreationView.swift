//
//  ToneCreationView.swift
//  Tona
//
//  Created by Apple Dev on 08/07/25.
//

import SwiftUI
import PhotosUI

struct ToneCreationView: View {
    var onToneCreated: (ToneStyle) -> Void = { _ in }
    @Binding var isGenerating: Bool
    @Binding var showError: Bool
    @StateObject private var viewModel = ToneCreationViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Reference Images Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reference Images")
                        .font(.headline)
                    
                    PhotosPicker(
                        selection: $viewModel.selectedItems,
                        maxSelectionCount: 5,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text("Pick Reference Images")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .onChange(of: viewModel.selectedItems) { _, _ in
                        viewModel.loadSelectedImages()
                    }
                    
                    if !viewModel.referenceImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(viewModel.referenceImages.enumerated()), id: \.offset) { index, image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .clipped()
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Tone Name Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tone Name")
                        .font(.headline)
                    
                    TextField("Enter tone name", text: $viewModel.toneName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Preview Section
                if let previewImage = viewModel.generatedPreviewImage {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Preview")
                            .font(.headline)
                        
                        Image(uiImage: previewImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                    }
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    if viewModel.isProcessing {
                        ProgressView("Processing...")
                            .padding()
                    } else {
                        Button("Generate Preview") {
                            viewModel.loadSelectedImages()
                        }
                        .disabled(viewModel.selectedItems.isEmpty)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        Button("Save Tone Style") {
                            // Simulate creating a new tone style
                            let newTone = ToneStyle(name: viewModel.toneName)
                            onToneCreated(newTone)
                        }
                        .disabled(viewModel.toneName.isEmpty || viewModel.generatedPreviewImage == nil)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Create Tone")
        .alert("Success", isPresented: $viewModel.showSuccessAlert) {
            Button("OK") { }
        } message: {
            Text("Tone style saved successfully!")
        }
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
