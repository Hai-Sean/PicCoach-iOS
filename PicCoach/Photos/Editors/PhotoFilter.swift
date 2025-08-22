//
//  PhotoFilter.swift
//  PicCoach
//
//  Created by Hoang Hai on 23/8/25.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - Filter Enum
enum PhotoFilterType: String, CaseIterable, Identifiable {
    case original = "Original"
    case sepia = "Sepia"
    case noir = "Noir"
    case chrome = "Chrome"
    case mono = "Mono"
    case fade = "Fade"
    case instant = "Instant"
    case tonal = "Tonal"
    case transfer = "Transfer"
    case process = "Process"
    
    var id: String { rawValue }
    var displayName: String { rawValue }
    
    /// Apply the filter to a CIImage
    func apply(to image: CIImage, context: CIContext) -> CIImage? {
        switch self {
        case .original:
            return image
        case .sepia:
            let f = CIFilter.sepiaTone()
            f.inputImage = image
            f.intensity = 1.0
            return f.outputImage
        case .noir:
            let f = CIFilter.photoEffectNoir()
            f.inputImage = image
            return f.outputImage
        case .chrome:
            let f = CIFilter.photoEffectChrome()
            f.inputImage = image
            return f.outputImage
        case .mono:
            let f = CIFilter.photoEffectMono()
            f.inputImage = image
            return f.outputImage
        case .fade:
            let f = CIFilter.photoEffectFade()
            f.inputImage = image
            return f.outputImage
        case .instant:
            let f = CIFilter.photoEffectInstant()
            f.inputImage = image
            return f.outputImage
        case .tonal:
            let f = CIFilter.photoEffectTonal()
            f.inputImage = image
            return f.outputImage
        case .transfer:
            let f = CIFilter.photoEffectTransfer()
            f.inputImage = image
            return f.outputImage
        case .process:
            let f = CIFilter.photoEffectProcess()
            f.inputImage = image
            return f.outputImage
        }
    }
}

// MARK: - Wrapper if you still want PhotoFilter struct
struct PhotoFilter: Identifiable {
    let id = UUID()
    let type: PhotoFilterType
    
    var name: String { type.displayName }
    var apply: (CIImage, CIContext) -> CIImage? {
        { image, context in type.apply(to: image, context: context) }
    }
}

// Convenience: generate all filters from enum
let availableFilters: [PhotoFilter] = PhotoFilterType.allCases.map { PhotoFilter(type: $0) }
