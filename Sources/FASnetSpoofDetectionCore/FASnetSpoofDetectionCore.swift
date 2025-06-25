//
//  FASnetSpoofDetectionCore.swift
//
//
//  Created by Jakub Dolejs on 23/06/2025.
//

import Foundation
import UIKit
import VerIDCommonTypes

open class FASnetSpoofDetectionCore: SpoofDetection {

    public var confidenceThreshold: Float = 0.5
    
    public init() throws {}
    
    public func detectSpoofInImage(_ image: VerIDCommonTypes.Image, regionOfInterest: CGRect?) async throws -> Float {
        guard let roi = regionOfInterest else {
            return 0
        }
        let images = try self.createInferenceImagesFromImage(image, roi: roi)
        return try await self.detectSpoofInImages(images)
    }
    
    open func detectSpoofInImages(_ images: [CGImage]) async throws -> Float {
        fatalError("Method not implemented")
    }
    
    public final func createInferenceImagesFromImage(_ image: Image, roi: CGRect) throws -> [CGImage] {
        guard let cgImage = image.toCGImage() else {
            throw ImageProcessingError.imageConversionFailed
        }
        let image1 = try  self.cropImage(cgImage, toBox: roi, scale: 2.7, outWidth: 80, outHeight: 80)
        let image2 = try self.cropImage(cgImage, toBox: roi, scale: 4.0, outWidth: 80, outHeight: 80)
        return [image1, image2]
    }
    
    private func cropImage(_ image: CGImage, toBox box: CGRect, scale: CGFloat, outWidth: Int, outHeight: Int) throws -> CGImage {
        
        let srcWidth = CGFloat(image.width)
        let srcHeight = CGFloat(image.height)
        
        let x = box.origin.x
        let y = box.origin.y
        let w = box.width
        let h = box.height
        
        // Clamp scale so that scaled box still fits in image
        let maxScale = min((srcHeight - 1) / h, (srcWidth - 1) / w)
        let clampedScale = min(scale, maxScale)
        
        let newWidth = w * clampedScale
        let newHeight = h * clampedScale
        
        let centerX = x + w / 2
        let centerY = y + h / 2
        
        var left = centerX - newWidth / 2
        var top = centerY - newHeight / 2
        var right = centerX + newWidth / 2
        var bottom = centerY + newHeight / 2
        
        // Adjust to keep within bounds
        if left < 0 {
            right -= left
            left = 0
        }
        if top < 0 {
            bottom -= top
            top = 0
        }
        if right > srcWidth - 1 {
            left -= right - (srcWidth - 1)
            right = srcWidth - 1
        }
        if bottom > srcHeight - 1 {
            top -= bottom - (srcHeight - 1)
            bottom = srcHeight - 1
        }
        
        // Convert to Int and clamp
        let cropRect = CGRect(
            x: max(0, Int(left)),
            y: max(0, Int(top)),
            width: min(Int(right - left), Int(srcWidth)),
            height: min(Int(bottom - top), Int(srcHeight))
        )
        
        guard let croppedCG = image.cropping(to: cropRect) else {
            throw ImageProcessingError.imageConversionFailed
        }
        
        let croppedUIImage = UIImage(cgImage: croppedCG)
        
        // Resize to (outWidth, outHeight)
        let outputSize = CGSize(width: outWidth, height: outHeight)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let resized = UIGraphicsImageRenderer(size: outputSize, format: format).image { ctx in
            croppedUIImage.draw(in: CGRect(origin: .zero, size: outputSize))
        }
        
        guard let result = resized.cgImage else {
            throw ImageProcessingError.imageConversionFailed
        }
        
        return result
    }
}
