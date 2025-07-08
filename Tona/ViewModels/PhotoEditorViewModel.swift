//
//  PhotoEditorViewModel.swift
//  Tona
//
//  Created by Apple Dev on 08/07/25.
//

import SwiftUI
import PhotosUI

@MainActor
class PhotoEditorViewModel: ObservableObject {
    @Published var selectedItem: PhotosPickerItem?
    @Published var originalImage: UIImage?
    @Published var processedImage: UIImage?
    @Published var selectedToneStyle: ToneStyle?
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var showManualEdit = false
    @Published var showPhotoPicker: Bool = false
    @Published var selectedItems: [PhotosPickerItem] = []
    
    // Manual edit properties
    @Published var brightness: Double = 0.0
    @Published var contrast: Double = 1.0
    @Published var saturation: Double = 1.0
    
    func loadSelectedImage() {
        guard let item = selectedItem else { return }
        
        isProcessing = true
        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let data, let uiImage = UIImage(data: data) {
                        self.originalImage = uiImage
                        self.processedImage = nil
                    }
                case .failure(let error):
                    self.errorMessage = "Failed to load image: \(error.localizedDescription)"
                }
                self.isProcessing = false
            }
        }
    }
    
    func loadSelectedImages(completion: @escaping ([UIImage]) -> Void) {
        let group = DispatchGroup()
        var images: [UIImage] = []
        for item in selectedItems {
            group.enter()
            item.loadTransferable(type: Data.self) { result in
                defer { group.leave() }
                if case .success(let data) = result, let data, let img = UIImage(data: data) {
                    images.append(img)
                }
            }
        }
        group.notify(queue: .main) {
            completion(images)
        }
    }
    
    func applyToneStyle(_ toneStyle: ToneStyle) {
        guard let original = originalImage else { return }
        
        isProcessing = true
        selectedToneStyle = toneStyle
        
        // Simulate AI processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.processedImage = self.simulateToneTransfer(original: original, toneStyle: toneStyle)
            self.isProcessing = false
        }
    }
    
    private func simulateToneTransfer(original: UIImage, toneStyle: ToneStyle) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: original.size)
        return renderer.image { context in
            original.draw(at: .zero)
            
            // Apply different effects based on tone style name
            switch toneStyle.name.lowercased() {
            case let name where name.contains("warm"):
                UIColor(red: 1.0, green: 0.8, blue: 0.6, alpha: 0.3).setFill()
            case let name where name.contains("cool"):
                UIColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 0.3).setFill()
            case let name where name.contains("contrast"):
                UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5).setFill()
            default:
                UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.2).setFill()
            }
            
            context.fill(CGRect(origin: .zero, size: original.size))
        }
    }
    
    func saveProcessedImage() {
        guard let image = processedImage ?? originalImage else { return }
        
        // TODO: Save to photo library
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        print("Image saved to photo library")
    }
    
    func shareProcessedImage() {
        guard let image = processedImage ?? originalImage else { return }
        
        // TODO: Implement sharing functionality
        print("Sharing image")
    }
    
    func resetToOriginal() {
        processedImage = nil
        selectedToneStyle = nil
        brightness = 0.0
        contrast = 1.0
        saturation = 1.0
    }
} 