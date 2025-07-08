//
//  ToneCollectionViewModel.swift
//  Tona
//
//  Created by Apple Dev on 08/07/25.
//

import SwiftUI

class ToneStyle: Hashable {
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
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ToneStyle, rhs: ToneStyle) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
class ToneCollectionViewModel: ObservableObject {
    @Published var toneStyles: [ToneStyle] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        loadMockToneStyles()
    }
    
    func loadMockToneStyles() {
        isLoading = true
        // Example mock data with real image URLs
        let mockTones: [(String, String)] = [
            ("Sunrises", "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=600&q=80"),
            ("Pinkies", "https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=600&q=80"),
            ("Vinyl Mood", "https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=600&q=80")
        ]
        
        Task {
            var tones: [ToneStyle] = []
            for (name, urlString) in mockTones {
                let imageData = await Self.fetchImageData(from: urlString)
                let tone = ToneStyle(name: name, previewImageData: imageData)
                tones.append(tone)
            }
            await MainActor.run {
                self.toneStyles = tones
                self.isLoading = false
            }
        }
    }
    
    static func fetchImageData(from urlString: String) async -> Data? {
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            return nil
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