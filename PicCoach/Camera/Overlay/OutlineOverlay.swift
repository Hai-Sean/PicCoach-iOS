//
//  OutlineOverlay.swift
//  PicCoach
//
//  Created by AI Assistant on 22/8/25.
//

import SwiftUI

struct OutlineOverlay: View {
    @Binding var isEnabled: Bool
    @Binding var opacity: Double
    @Binding var selectedImage: UIImage?
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    @Binding var rotation: Double
    @State private var lastOffset = CGSize.zero
    @State private var isDragging = false
    @State private var lastRotation = 0.0
    
    var body: some View {
        if isEnabled, let image = selectedImage {
            GeometryReader { geo in
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: geo.size.width, maxHeight: geo.size.height)
                    .scaleEffect(scale)
                    .offset(offset)
                    .rotationEffect(.degrees(rotation))
                    .opacity(opacity)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !isDragging {
                                    isDragging = true
                                    lastOffset = offset
                                }
                                offset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = value
                            }
                    )
                    .gesture(
                        RotationGesture()
                            .onChanged { value in
                                if !isDragging {
                                    lastRotation = rotation
                                }
                                rotation = lastRotation + value.degrees
                            }
                    )
                    .allowsHitTesting(true)
            }
        }
    }
}

struct OutlineOverlayControls: View {
    @Binding var isEnabled: Bool
    @Binding var opacity: Double
    @Binding var selectedImage: UIImage?
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    @Binding var rotation: Double
    @State private var showingImagePicker = false
    
    var body: some View {
        VStack(spacing: 12) {
            
            if isEnabled && selectedImage != nil {
                // Image selection
                HStack {                    
                    Spacer()
                    
                    // Remove image button
                    if selectedImage != nil {
                        Button(action: {
                            selectedImage = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 16))
                        }
                    }
                    
                    // Reset position button
                    if selectedImage != nil {
                        Button(action: {
                            // Reset position, scale and rotation
                            withAnimation(.easeInOut(duration: 0.3)) {
                                self.scale = 1.0
                                self.offset = .zero
                                self.rotation = 0.0
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.6))
                        .cornerRadius(6)
                    }
                    
                }
                
                // Opacity slider
                VStack(alignment: .leading, spacing: 4) { 
                    Slider(value: $opacity, in: 0.1...1.0, step: 0.02)
                        .accentColor(Color(red: 0.73, green: 0.87, blue: 0.21)) // #BADD35
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
