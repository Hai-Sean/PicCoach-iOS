import SwiftUI
import Photos
import CoreImage
import CoreImage.CIFilterBuiltins

struct TechnicalityPreviewView: View {
    let originalImage: UIImage
    let adjustments: (brightness: Double, contrast: Double, saturation: Double, exposure: Double)
    
    @Environment(\.dismiss) var dismiss
    @State private var adjustedImage: UIImage?
    @State private var isSaving = false
    @State private var saveSuccess: Bool?

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }

                Spacer()
                
                // Show adjusted image when ready, else show original
                if let image = adjustedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding()
                } else {
                    Image(uiImage: originalImage)
                        .resizable()
                        .scaledToFit()
                        .padding()
                }

                Spacer()
                
                // Save button
                Button(action: saveToPhotos) {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Save to Photos")
                                .bold()
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                }
                .disabled(isSaving)
            }
        }
        .onAppear(perform: applyAdjustments)
        .alert("Saved!", isPresented: Binding(get: { saveSuccess == true }, set: { _ in saveSuccess = nil })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Image saved to your photo library.")
        }
    }

    private func applyAdjustments() {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let ciImage = CIImage(image: originalImage) else { return }

            let filter = CIFilter.colorControls()
            filter.inputImage = ciImage
            filter.brightness = Float(adjustments.brightness)
            filter.contrast = Float(adjustments.contrast)
            filter.saturation = Float(adjustments.saturation)

            let exposureFilter = CIFilter.exposureAdjust()
            exposureFilter.inputImage = filter.outputImage
            exposureFilter.ev = Float(adjustments.exposure)

            guard let output = exposureFilter.outputImage else { return }

            let context = CIContext()
            if let cgImage = context.createCGImage(output, from: output.extent) {
                let uiImage = UIImage(cgImage: cgImage, scale: originalImage.scale, orientation: originalImage.imageOrientation)
                DispatchQueue.main.async {
                    self.adjustedImage = uiImage
                }
            }
        }
    }

    private func saveToPhotos() {
        let image = adjustedImage ?? originalImage
        isSaving = true
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { success, error in
            DispatchQueue.main.async {
                isSaving = false
                if success {
                    saveSuccess = true
                } else {
                    print("Error saving image: \(error?.localizedDescription ?? "")")
                }
            }
        }
    }
}
