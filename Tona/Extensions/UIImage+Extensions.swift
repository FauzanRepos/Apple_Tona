//
//  UIImage+Extensions.swift
//  Tona
//
//  Created by Apple Dev on 08/07/25.
//

import UIKit

extension UIImage {
    
    // MARK: - Image Processing
    
    func applyingFilter(_ filter: (UIImage) -> UIImage?) -> UIImage? {
        return filter(self)
    }
    
    func applyingMultipleFilters(_ filters: [(UIImage) -> UIImage?]) -> UIImage? {
        var currentImage = self
        for filter in filters {
            guard let filtered = filter(currentImage) else { return nil }
            currentImage = filtered
        }
        return currentImage
    }
    
    // MARK: - Image Utilities
    
    func resized(to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func resized(by scale: CGFloat) -> UIImage? {
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        return resized(to: newSize)
    }
    
    func cropped(to rect: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - Data Conversion
    
    func toData(quality: CGFloat = 0.8) -> Data? {
        return self.jpegData(compressionQuality: quality)
    }
    
    func toPNGData() -> Data? {
        return self.pngData()
    }
    
    // MARK: - Color Analysis
    
    func averageColor() -> UIColor? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        let totalPixels = width * height
        
        guard let data = cgImage.dataProvider?.data,
              let bytes = CFDataGetBytePtr(data) else { return nil }
        
        var totalRed: Int = 0
        var totalGreen: Int = 0
        var totalBlue: Int = 0
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * 4
                totalRed += Int(bytes[pixelIndex])
                totalGreen += Int(bytes[pixelIndex + 1])
                totalBlue += Int(bytes[pixelIndex + 2])
            }
        }
        
        let avgRed = CGFloat(totalRed) / CGFloat(totalPixels) / 255.0
        let avgGreen = CGFloat(totalGreen) / CGFloat(totalPixels) / 255.0
        let avgBlue = CGFloat(totalBlue) / CGFloat(totalPixels) / 255.0
        
        return UIColor(red: avgRed, green: avgGreen, blue: avgBlue, alpha: 1.0)
    }
    
    // MARK: - Metadata
    
    var aspectRatio: CGFloat {
        return size.width / size.height
    }
    
    var isPortrait: Bool {
        return size.height > size.width
    }
    
    var isLandscape: Bool {
        return size.width > size.height
    }
    
    var isSquare: Bool {
        return abs(size.width - size.height) < 0.1
    }
} 