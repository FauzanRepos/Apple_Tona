//
//  PhotoProcessingService.swift
//  Tona
//
//  Created by Apple Dev on 08/07/25.
//

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

class PhotoProcessingService {
    static let shared = PhotoProcessingService()
    
    private let context = CIContext()
    
    private init() {}
    
    // MARK: - Manual Adjustments
    
    func applyManualAdjustments(
        to image: UIImage,
        brightness: Double,
        contrast: Double,
        saturation: Double
    ) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.brightness = Float(brightness)
        filter.contrast = Float(contrast)
        filter.saturation = Float(saturation)
        
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - Advanced Filters
    
    func applyVintageFilter(to image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        // Apply sepia filter
        let sepiaFilter = CIFilter.sepiaTone()
        sepiaFilter.inputImage = ciImage
        sepiaFilter.intensity = 0.8
        
        guard let sepiaOutput = sepiaFilter.outputImage else { return nil }
        
        // Apply vignette
        let vignetteFilter = CIFilter.vignette()
        vignetteFilter.inputImage = sepiaOutput
        vignetteFilter.intensity = 0.5
        vignetteFilter.radius = 1.0
        
        guard let outputImage = vignetteFilter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    func applyCoolFilter(to image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        // Apply temperature adjustment (cooler)
        let temperatureFilter = CIFilter.temperatureAndTint()
        temperatureFilter.inputImage = ciImage
        temperatureFilter.neutral = CIVector(x: 6500, y: 0)
        temperatureFilter.targetNeutral = CIVector(x: 4000, y: 0) // Cooler temperature
        
        guard let outputImage = temperatureFilter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    func applyHighContrastFilter(to image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        // Apply high contrast
        let contrastFilter = CIFilter.colorControls()
        contrastFilter.inputImage = ciImage
        contrastFilter.contrast = 1.5
        contrastFilter.saturation = 1.2
        
        guard let outputImage = contrastFilter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - Image Utilities
    
    func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func cropImage(_ image: UIImage, to rect: CGRect) -> UIImage? {
        guard let cgImage = image.cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    func saveImageToPhotos(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    // MARK: - Image Analysis
    
    func getImageMetadata(from image: UIImage) -> ImageMetadata {
        let size = image.size
        let scale = image.scale
        
        return ImageMetadata(
            width: Int(size.width * scale),
            height: Int(size.height * scale),
            aspectRatio: size.width / size.height,
            fileSize: estimateFileSize(for: image)
        )
    }
    
    private func estimateFileSize(for image: UIImage) -> Int {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return 0 }
        return data.count
    }
}

// MARK: - Supporting Types

struct ImageMetadata {
    let width: Int
    let height: Int
    let aspectRatio: CGFloat
    let fileSize: Int
} 