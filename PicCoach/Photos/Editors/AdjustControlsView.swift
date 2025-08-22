//
//  AdjustControlsView.swift
//  PicCoach
//
//  Created by Hoang Hai on 23/8/25.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct AdjustControlsView: View {
    var photo: UIImage

    @Binding var exposure: Double
    @Binding var brightness: Double
    @Binding var contrast: Double
    @Binding var saturation: Double

    private let context = CIContext()

    private var adjustedImage: UIImage {
        guard let input = CIImage(image: photo) else { return photo }
        var output = input

        // Exposure
        let exposureFilter = CIFilter.exposureAdjust()
        exposureFilter.inputImage = output
        exposureFilter.ev = Float(exposure)
        if let result = exposureFilter.outputImage {
            output = result
        }

        // Brightness / Contrast / Saturation
        let cc = CIFilter.colorControls()
        cc.inputImage = output
        cc.brightness = Float(brightness)
        cc.contrast = Float(contrast)
        cc.saturation = Float(saturation)
        if let result = cc.outputImage {
            output = result
        }

        if let cg = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cg)
        }
        return photo
    }

    var body: some View {
        VStack {
            // Image preview
            Image(uiImage: adjustedImage)
                .resizable()
                .scaledToFit()

            AdjustmentsView(
                exposure: $exposure,
                brightness: $brightness,
                contrast: $contrast,
                saturation: $saturation
            )
            .frame(height: 120)
            .ignoresSafeArea(edges: .all)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
