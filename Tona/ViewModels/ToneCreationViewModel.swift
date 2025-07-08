//
//  ToneCreationViewModel.swift
//  Tona
//
//  Created by Apple Dev on 08/07/25.
//

import SwiftUI
import PhotosUI

@MainActor
class ToneCreationViewModel: ObservableObject {
    @Published var selectedItems: [PhotosPickerItem] = []
    @Published var referenceImages: [UIImage] = []
    @Published var generatedPreviewImage: UIImage?
    @Published var toneName: String = ""
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var showSuccessAlert = false
    
    func loadSelectedImages() {
        guard !selectedItems.isEmpty else { return }
        
        isProcessing = true
        referenceImages.removeAll()
        
        let group = DispatchGroup()
        
        for item in selectedItems {
            group.enter()
            item.loadTransferable(type: Data.self) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        if let data, let uiImage = UIImage(data: data) {
                            self.referenceImages.append(uiImage)
                        }
                    case .failure(let error):
                        self.errorMessage = "Failed to load image: \(error.localizedDescription)"
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            self.generateTonePreview()
        }
    }
    
    private func generateTonePreview() {
        guard !referenceImages.isEmpty else {
            isProcessing = false
            return
        }
        
        // Simulate AI processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let firstImage = self.referenceImages.first {
                // Create a simple preview by applying a filter
                self.generatedPreviewImage = self.createPreviewImage(from: firstImage)
            }
            self.isProcessing = false
        }
    }
    
    private func createPreviewImage(from image: UIImage) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { context in
            image.draw(at: .zero)
            // Apply a simple vintage filter effect
            UIColor(red: 0.9, green: 0.8, blue: 0.6, alpha: 0.3).setFill()
            context.fill(CGRect(origin: .zero, size: image.size))
        }
    }
    
    func saveToneStyle() {
        guard !toneName.isEmpty, let previewImage = generatedPreviewImage else {
            errorMessage = "Please provide a tone name and generate a preview first"
            return
        }
        
        // TODO: Save to SwiftData
        print("Saving tone style: \(toneName)")
        showSuccessAlert = true
        
        // Reset form
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.resetForm()
        }
    }
    
    private func resetForm() {
        toneName = ""
        selectedItems.removeAll()
        referenceImages.removeAll()
        generatedPreviewImage = nil
        showSuccessAlert = false
    }
} 