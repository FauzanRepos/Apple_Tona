//
//  ToneCollectionViewModel.swift
//  Tona
//
//  Created by Apple Dev on 08/07/25.
//

import SwiftUI

class ToneStyle {
    var id: UUID
    var name: String
    var previewImageData: Data?
    var createdAt: Date
    var referenceImagesData: [Data]
    
    init(name: String, previewImageData: Data? = nil, referenceImagesData: [Data] = []) {
        self.id = UUID()
        self.name = name
        self.previewImageData = previewImageData
        self.createdAt = Date()
        self.referenceImagesData = referenceImagesData
    }
}

@MainActor
class ToneCollectionViewModel: ObservableObject {
    @Published var toneStyles: [ToneStyle] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        loadToneStyles()
    }
    
    func loadToneStyles() {
        isLoading = true
        // TODO: Load from SwiftData
        // For now, create some sample data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.toneStyles = [
                ToneStyle(name: "Vintage Warm", referenceImagesData: []),
                ToneStyle(name: "Cool Blue", referenceImagesData: []),
                ToneStyle(name: "High Contrast", referenceImagesData: [])
            ]
            self.isLoading = false
        }
    }
    
    func deleteToneStyle(_ toneStyle: ToneStyle) {
        toneStyles.removeAll { $0.id == toneStyle.id }
        // TODO: Delete from SwiftData
    }
    
    func selectToneStyle(_ toneStyle: ToneStyle) {
        // TODO: Navigate to photo editor with selected tone
        print("Selected tone style: \(toneStyle.name)")
    }
} 