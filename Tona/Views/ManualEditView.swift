//
//  ManualEditView.swift
//  Tona
//
//  Created by Apple Dev on 08/07/25.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ManualEditView: View {
    let inputImage: UIImage
    
    @State private var brightness: Double = 0.0
    @State private var contrast: Double = 1.0
    @State private var saturation: Double = 1.0
    @State private var processedImage: UIImage?
    @State private var showSaveAlert = false
    
    private let photoService = PhotoProcessingService.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Image Display
                if let output = processedImage {
                    Image(uiImage: output)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                } else {
                    Image(uiImage: inputImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                
                // Adjustment Controls
                VStack(spacing: 20) {
                    AdjustmentSlider(
                        value: $brightness,
                        range: -1...1,
                        title: "Brightness",
                        icon: "sun.max"
                    )
                    
                    AdjustmentSlider(
                        value: $contrast,
                        range: 0.5...2.0,
                        title: "Contrast",
                        icon: "circle.lefthalf.filled"
                    )
                    
                    AdjustmentSlider(
                        value: $saturation,
                        range: 0.0...2.0,
                        title: "Saturation",
                        icon: "drop"
                    )
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button("Apply Changes") {
                        applyAdjustments()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    HStack(spacing: 12) {
                        Button("Save to Photos") {
                            let image = processedImage ?? inputImage
                            photoService.saveImageToPhotos(image)
                            showSaveAlert = true
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        Button("Reset") {
                            resetAdjustments()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Manual Edit")
        .onAppear {
            applyAdjustments() // apply initial values
        }
        .onChange(of: brightness) { _, _ in applyAdjustments() }
        .onChange(of: contrast) { _, _ in applyAdjustments() }
        .onChange(of: saturation) { _, _ in applyAdjustments() }
        .alert("Saved", isPresented: $showSaveAlert) {
            Button("OK") { }
        } message: {
            Text("Image saved to photo library")
        }
    }

    private func applyAdjustments() {
        processedImage = photoService.applyManualAdjustments(
            to: inputImage,
            brightness: brightness,
            contrast: contrast,
            saturation: saturation
        )
    }
    
    private func resetAdjustments() {
        brightness = 0.0
        contrast = 1.0
        saturation = 1.0
        processedImage = nil
    }
}

struct AdjustmentSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let title: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
                Spacer()
                Text("\(value, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Slider(value: $value, in: range, step: 0.01)
                .accentColor(.blue)
        }
    }
}
