//
//  EnhancedPreviewView.swift
//  PicCoach
//
//  Created by Hoang Hai on 23/8/25.
//

import SwiftUI
import Photos

struct EnhancedPreviewView: View {
    let image: UIImage
    
    @Environment(\.dismiss) var dismiss
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
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
                
                Spacer()
                
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
        .alert("Saved!", isPresented: Binding(get: { saveSuccess == true }, set: { _ in saveSuccess = nil })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Image saved to your photo library.")
        }
    }
    
    private func saveToPhotos() {
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
