//
//  Ults.swift
//  PicCoach
//
//  Created by Hoang Hai on 22/8/25.
//

import SwiftUI
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit, e.g. FFF)
            (a, r, g, b) = (255, (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RGB (24-bit, e.g. FFFFFF)
            (a, r, g, b) = (255, int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // ARGB (32-bit, e.g. FFFFFFFF)
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension UIImage {
    func fixedOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage ?? self
    }
}

// MARK: - UIImage resize helper
extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result ?? self
    }
}

extension UIImage {
    func applyingAdjustments(exposure: Double,
                             brightness: Double,
                             contrast: Double,
                             saturation: Double) -> UIImage? {
        let ciImage = CIImage(image: self)
        let context = CIContext()

        guard let input = ciImage else { return nil }
        var output = input

        // Exposure
        if let filter = CIFilter(name: "CIExposureAdjust") {
            filter.setValue(output, forKey: kCIInputImageKey)
            filter.setValue(exposure, forKey: kCIInputEVKey)
            if let result = filter.outputImage {
                output = result
            }
        }

        // Brightness, Contrast, Saturation (via CIColorControls)
        if let filter = CIFilter(name: "CIColorControls") {
            filter.setValue(output, forKey: kCIInputImageKey)
            filter.setValue(brightness, forKey: kCIInputBrightnessKey)
            filter.setValue(contrast, forKey: kCIInputContrastKey)
            filter.setValue(saturation, forKey: kCIInputSaturationKey)
            if let result = filter.outputImage {
                output = result
            }
        }

        // Render to UIImage
        if let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}

extension UIImage {
    func scaled(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let result = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return result
    }
}


extension UIImage {
    func blendImages(filtered: UIImage, opacity: Double) -> UIImage {
        let size = self.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        filtered.draw(in: CGRect(origin: .zero, size: size), blendMode: .normal, alpha: CGFloat(opacity))
        let blended = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return blended ?? self
    }
}
