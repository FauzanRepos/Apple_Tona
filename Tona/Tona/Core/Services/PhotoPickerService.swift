//
//  PhotoPickerService.swift
//  Tona
//
//  Created by Apple Dev on 06/09/25.
//

import SwiftUI
import PhotosUI
import UIKit

class PhotoPickerService: ObservableObject {
    @Published var selectedImages: [UIImage] = []
    @Published var isPresented = false
    
    func presentPhotoPicker() {
        isPresented = true
    }
    
    func handlePhotoPickerResult(_ result: Result<[PhotosPickerItem], Error>) {
        switch result {
        case .success(let items):
            Task {
                await loadImages(from: items)
            }
        case .failure(let error):
            print("Photo picker error: \(error)")
        }
    }
    
    @MainActor
    private func loadImages(from items: [PhotosPickerItem]) async {
        selectedImages.removeAll()
        
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImages.append(image)
            }
        }
    }
    
    func clearSelection() {
        selectedImages.removeAll()
    }
    
    func removeImage(at index: Int) {
        guard index < selectedImages.count else { return }
        selectedImages.remove(at: index)
    }
}
