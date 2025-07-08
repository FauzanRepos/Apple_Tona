//
//  CoreImageExtensions.swift
//  Tona
//
//  Created by Apple Dev on 08/07/25.
//

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

extension CIImage {
    func applyingBrightness(_ value: Float) -> CIImage? {
        let filter = CIFilter.colorControls()
        filter.inputImage = self
        filter.brightness = value
        return filter.outputImage
    }
    
    func applyingContrast(_ value: Float) -> CIImage? {
        let filter = CIFilter.colorControls()
        filter.inputImage = self
        filter.contrast = value
        return filter.outputImage
    }
    
    func applyingSaturation(_ value: Float) -> CIImage? {
        let filter = CIFilter.colorControls()
        filter.inputImage = self
        filter.saturation = value
        return filter.outputImage
    }
    
    func applyingSepia(intensity: Float = 0.8) -> CIImage? {
        let filter = CIFilter.sepiaTone()
        filter.inputImage = self
        filter.intensity = intensity
        return filter.outputImage
    }
    
    func applyingVignette(intensity: Float = 0.5, radius: Float = 1.0) -> CIImage? {
        let filter = CIFilter.vignette()
        filter.inputImage = self
        filter.intensity = intensity
        filter.radius = radius
        return filter.outputImage
    }
    
    func applyingGaussianBlur(radius: Float = 10.0) -> CIImage? {
        let filter = CIFilter.gaussianBlur()
        filter.inputImage = self
        filter.radius = radius
        return filter.outputImage
    }
    
    func applyingSharpen(intensity: Float = 0.5) -> CIImage? {
        let filter = CIFilter.sharpenLuminance()
        filter.inputImage = self
        filter.sharpness = intensity
        return filter.outputImage
    }
    
    func applyingTemperature(_ temperature: Float, tint: Float = 0.0) -> CIImage? {
        let filter = CIFilter.temperatureAndTint()
        filter.inputImage = self
        filter.neutral = CIVector(x: CGFloat(temperature), y: CGFloat(tint))
        filter.targetNeutral = CIVector(x: CGFloat(temperature), y: CGFloat(tint))
        return filter.outputImage
    }
}

extension UIImage {
    func applyingCoreImageFilter(_ filter: (CIImage) -> CIImage?) -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }
        guard let filteredCIImage = filter(ciImage) else { return nil }
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(filteredCIImage, from: filteredCIImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    func applyingBrightness(_ value: Float) -> UIImage? {
        return applyingCoreImageFilter { $0.applyingBrightness(value) }
    }
    
    func applyingContrast(_ value: Float) -> UIImage? {
        return applyingCoreImageFilter { $0.applyingContrast(value) }
    }
    
    func applyingSaturation(_ value: Float) -> UIImage? {
        return applyingCoreImageFilter { $0.applyingSaturation(value) }
    }
    
    func applyingSepia(intensity: Float = 0.8) -> UIImage? {
        return applyingCoreImageFilter { $0.applyingSepia(intensity: intensity) }
    }
    
    func applyingVignette(intensity: Float = 0.5, radius: Float = 1.0) -> UIImage? {
        return applyingCoreImageFilter { $0.applyingVignette(intensity: intensity, radius: radius) }
    }
    
    func applyingGaussianBlur(radius: Float = 10.0) -> UIImage? {
        return applyingCoreImageFilter { $0.applyingGaussianBlur(radius: radius) }
    }
    
    func applyingSharpen(intensity: Float = 0.5) -> UIImage? {
        return applyingCoreImageFilter { $0.applyingSharpen(intensity: intensity) }
    }
    
    func applyingTemperature(_ temperature: Float, tint: Float = 0.0) -> UIImage? {
        return applyingCoreImageFilter { $0.applyingTemperature(temperature, tint: tint) }
    }
}

// MARK: - Filter Presets

extension UIImage {
    static func createVintageFilter() -> (UIImage) -> UIImage? {
        return { image in
            image.applyingSepia(intensity: 0.8)?
                .applyingVignette(intensity: 0.5, radius: 1.0)?
                .applyingBrightness(-0.1)?
                .applyingContrast(1.1)
        }
    }
    
    static func createCoolFilter() -> (UIImage) -> UIImage? {
        return { image in
            image.applyingTemperature(4000, tint: -0.1)?
                .applyingSaturation(0.8)?
                .applyingContrast(1.2)
        }
    }
    
    static func createWarmFilter() -> (UIImage) -> UIImage? {
        return { image in
            image.applyingTemperature(7000, tint: 0.1)?
                .applyingSaturation(1.2)?
                .applyingBrightness(0.1)
        }
    }
    
    static func createHighContrastFilter() -> (UIImage) -> UIImage? {
        return { image in
            image.applyingContrast(1.5)?
                .applyingSaturation(1.2)?
                .applyingSharpen(intensity: 0.3)
        }
    }
} 