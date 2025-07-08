//
//  FastAPIToneService.swift
//  Tona
//
//  Created by Apple Dev on 08/07/25.
//

import Foundation
import UIKit

actor FastAPIToneService {
    static let shared = FastAPIToneService()
    private init() {}
    
    enum FastAPIError: Error, LocalizedError {
        case networkError
        case invalidResponse
        case processingFailed
        
        var errorDescription: String? {
            switch self {
            case .networkError: return "Network error. Please try again."
            case .invalidResponse: return "Invalid response from server."
            case .processingFailed: return "Failed to process image."
            }
        }
    }
    
    /// Simulate uploading reference images and getting a tone ID
    func uploadReferenceImages(_ images: [UIImage]) async throws -> String {
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1s delay
        if Bool.random() { // Simulate occasional network error
            throw FastAPIError.networkError
        }
        // Return a mock tone ID
        return UUID().uuidString
    }
    
    /// Simulate applying a tone to a photo and returning a processed image
    func applyTone(to image: UIImage, toneID: String) async throws -> UIImage {
        try await Task.sleep(nanoseconds: 1_200_000_000) // 1.2s delay
        if Bool.random() { // Simulate occasional error
            throw FastAPIError.processingFailed
        }
        // Return a mock processed image (tint the image for demo)
        return tintImage(image, color: .systemBlue.withAlphaComponent(0.25))
    }
    
    /// Helper: Tint an image with a color
    private func tintImage(_ image: UIImage, color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { context in
            image.draw(at: .zero)
            color.setFill()
            context.fill(CGRect(origin: .zero, size: image.size))
        }
    }
} 