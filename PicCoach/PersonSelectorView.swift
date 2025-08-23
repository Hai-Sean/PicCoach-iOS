//
//  PersonSelectorView.swift
//  PicCoach
//
//  Created by AI Assistant on 21/8/25.
//

import SwiftUI

struct ProcessedImage: Identifiable {
    let id = UUID()
    let originalImage: UIImage
    let segmentedImage: UIImage?
    let isProcessing: Bool
    let error: String?
    
    init(originalImage: UIImage, segmentedImage: UIImage? = nil, isProcessing: Bool = true, error: String? = nil) {
        self.originalImage = originalImage
        self.segmentedImage = segmentedImage
        self.isProcessing = isProcessing
        self.error = error
    }
}

struct PersonSelectorView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var outlineOverlayImage: UIImage?
    let cameraMode: CameraMode
    @State private var selectedPersonCount = "1 Person"
    @State private var showDropdown = false
    @State private var showingImagePicker = false
    @State private var processedImages: [ProcessedImage] = []
    
    let personOptions = ["1 Person"]
    
    private var segmentEndpoint: APIEndpoint {
        switch cameraMode {
        case .people:
            return .segmentHuman
        case .product:
            return .segmentObject
        case .classic:
            return .segmentObject // Default to object segmentation for classic mode
        }
    }
    
    var body: some View {
        ZStack {
        
            VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        ZStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .medium))
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                
                // Person Selection Dropdown
                VStack(spacing: 10) {
                    // Text Field Button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showDropdown.toggle()
                        }
                    }) {
                        HStack {
                            Text(selectedPersonCount)
                                .font(.custom("Geist", size: 14))
                                .fontWeight(.regular)
                                .foregroundColor(Color(red: 247/255, green: 247/255, blue: 248/255))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(Color(red: 247/255, green: 247/255, blue: 248/255))
                                .font(.system(size: 12, weight: .medium))
                                .rotationEffect(.degrees(showDropdown ? 180 : 0))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 2)
                        .frame(height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(red: 228/255, green: 255/255, blue: 90/255).opacity(0.05))
                                .stroke(Color(red: 249/255, green: 255/255, blue: 201/255), lineWidth: 1)
                        )
                    }
                    .overlay(
                        // Dropdown Menu - Absolute positioned
                        Group {
                            if showDropdown {
                                VStack(spacing: 0) {
                                    ForEach(personOptions, id: \.self) { option in
                                        Button(action: {
                                            selectedPersonCount = option
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                showDropdown = false
                                            }
                                        }) {
                                            HStack {
                                                Text(option)
                                                    .font(.custom("Geist", size: 14))
                                                    .fontWeight(option == selectedPersonCount ? .medium : .regular)
                                                    .foregroundColor(option == selectedPersonCount ? 
                                                        Color(red: 228/255, green: 255/255, blue: 90/255) : 
                                                        Color(red: 247/255, green: 247/255, blue: 248/255))
                                                Spacer()
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .frame(height: 56)
                                            .background(Color.clear)
                                        }
                                    }
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.1))
                                        .background(.ultraThinMaterial)
                                )
                                .offset(y: 50)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
                                    removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .top))
                                ))
                            }
                        }
                        , alignment: .topLeading
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .zIndex(1)
                
                // Photo Grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        // Upload button
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 228/255, green: 255/255, blue: 90/255).opacity(0.05))
                                        .stroke(Color(red: 88/255, green: 105/255, blue: 30/255), lineWidth: 1)
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "plus")
                                        .foregroundColor(Color(red: 228/255, green: 255/255, blue: 90/255))
                                        .font(.system(size: 16, weight: .medium))
                                }
                                
                                Text("Upload")
                                    .font(.custom("Geist", size: 14))
                                    .fontWeight(.regular)
                                    .foregroundColor(Color(red: 228/255, green: 255/255, blue: 90/255))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 233)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(red: 228/255, green: 255/255, blue: 90/255).opacity(0.03))
                                    .stroke(Color(red: 69/255, green: 69/255, blue: 74/255), lineWidth: 1)
                            )
                        }
                        
                        // Default sample pose
                        PhotoOutlineItem(imageName: "sample_pose") {
                            if let sampleImage = UIImage(named: "sample_pose") {
                                outlineOverlayImage = sampleImage
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                        
                        // Uploaded and processed images
                        ForEach(processedImages) { processedImage in
                            ProcessedImageItem(processedImage: processedImage, onTap: {
                                if let segmentedImage = processedImage.segmentedImage {
                                    outlineOverlayImage = segmentedImage
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }, onRetry: {
                                retryImageProcessing(processedImage)
                            })
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
            }
        }
        .background(Color.black.opacity(0.8))
        .navigationBarHidden(true)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: Binding(
                get: { nil },
                set: { newImage in
                    if let image = newImage {
                        processUploadedImage(image)
                    }
                }
            ))
        }
    }
    
    private func processUploadedImage(_ image: UIImage) {
        print("📸 Image selected, starting processing...")
        
        // Add the image to the list with processing state immediately
        let processedImage = ProcessedImage(originalImage: image, isProcessing: true)
        processedImages.append(processedImage)
        
        print("📋 Added image to processedImages list. Current count: \(processedImages.count)")
        
        // Force UI update on main thread
        DispatchQueue.main.async {
            // This ensures the UI updates immediately
            print("🔄 UI update triggered")
        }
        
        // Process the image asynchronously
        Task {
            print("⏳ Starting async processing...")
            
            // Small delay to ensure loading state is visible for testing
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            do {
                print("🌐 Calling APIService with mode: \(cameraMode.rawValue)")
                print("📡 Selected endpoint: \(segmentEndpoint)")
                let segmentedImage = try await APIService.shared.uploadFileAsImage(
                    endpoint: segmentEndpoint,
                    image: image
                )
                
                // Update the processed image on main thread
                await MainActor.run {
                    if let index = processedImages.firstIndex(where: { $0.id == processedImage.id }) {
                        processedImages[index] = ProcessedImage(
                            originalImage: image,
                            segmentedImage: segmentedImage,
                            isProcessing: false,
                            error: nil
                        )
                    }
                }
            } catch {
                // Handle segmentation error
                await MainActor.run {
                    if let index = processedImages.firstIndex(where: { $0.id == processedImage.id }) {
                        processedImages[index] = ProcessedImage(
                            originalImage: image,
                            segmentedImage: nil,
                            isProcessing: false,
                            error: error.localizedDescription
                        )
                    }
                }
            }
        }
    }
    
    private func retryImageProcessing(_ failedImage: ProcessedImage) {
        // Update the image to processing state
        if let index = processedImages.firstIndex(where: { $0.id == failedImage.id }) {
            processedImages[index] = ProcessedImage(
                originalImage: failedImage.originalImage,
                segmentedImage: nil,
                isProcessing: true,
                error: nil
            )
            
            // Process the image again
            let imageToProcess = failedImage.originalImage
            let imageId = failedImage.id
            
            Task {
                do {
                    print("🔄 Retrying with mode: \(cameraMode.rawValue)")
                    print("📡 Retry endpoint: \(segmentEndpoint)")
                    let segmentedImage = try await APIService.shared.uploadFileAsImage(
                        endpoint: segmentEndpoint,
                        image: imageToProcess
                    )
                    
                    // Update the processed image on main thread
                    await MainActor.run {
                        if let index = processedImages.firstIndex(where: { $0.id == imageId }) {
                            processedImages[index] = ProcessedImage(
                                originalImage: imageToProcess,
                                segmentedImage: segmentedImage,
                                isProcessing: false,
                                error: nil
                            )
                        }
                    }
                } catch {
                    // Handle segmentation error
                    await MainActor.run {
                        if let index = processedImages.firstIndex(where: { $0.id == imageId }) {
                            processedImages[index] = ProcessedImage(
                                originalImage: imageToProcess,
                                segmentedImage: nil,
                                isProcessing: false,
                                error: error.localizedDescription
                            )
                        }
                    }
                }
            }
        }
    }
}

struct ProcessedImageItem: View {
    let processedImage: ProcessedImage
    let onTap: () -> Void
    let onRetry: () -> Void
    
    var body: some View {
        Button(action: {
            if !processedImage.isProcessing && processedImage.segmentedImage != nil {
                onTap()
            }
        }) {
            ZStack {
                // Background container
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 28/255, green: 28/255, blue: 30/255))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 69/255, green: 69/255, blue: 74/255), lineWidth: 1)
                    )
                
                if processedImage.isProcessing {
                    // Loading state with original image as background
                    ZStack {
                        Image(uiImage: processedImage.originalImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .frame(height: 209)
                            .padding(12)
                            .clipped()
                            .opacity(0.3)
                        
                        // Dark overlay
                        Color.black.opacity(0.4)
                            .frame(maxWidth: .infinity)
                            .frame(height: 209)
                            .padding(12)
                        
                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 228/255, green: 255/255, blue: 90/255)))
                                .scaleEffect(1.5)
                            
                            VStack(spacing: 4) {
                                Text("Processing...")
                                    .font(.custom("Geist", size: 14))
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                
                                Text("Segmenting image")
                                    .font(.custom("Geist", size: 11))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black.opacity(0.8))
                            )
                        }
                    }
                } else if let error = processedImage.error {
                    // Error state
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                            .font(.system(size: 24))
                        
                        Text("Processing failed")
                            .font(.custom("Geist", size: 12))
                            .foregroundColor(.red)
                        
                        Text(error)
                            .font(.custom("Geist", size: 10))
                            .foregroundColor(Color(red: 247/255, green: 247/255, blue: 248/255).opacity(0.7))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        
                        Button("Retry") {
                            onRetry()
                        }
                        .font(.custom("Geist", size: 11))
                        .foregroundColor(Color(red: 228/255, green: 255/255, blue: 90/255))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(red: 228/255, green: 255/255, blue: 90/255), lineWidth: 1)
                        )
                    }
                    .padding(8)
                } else if let segmentedImage = processedImage.segmentedImage {
                    // Success state - show segmented image with success indicator
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: segmentedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .frame(height: 209)
                            .padding(12)
                            .clipped()
                        
                        // Success indicator
                        ZStack {
                            Circle()
                                .fill(Color(red: 228/255, green: 255/255, blue: 90/255))
                                .frame(width: 24, height: 24)
                            
                            Image(systemName: "checkmark")
                                .foregroundColor(.black)
                                .font(.system(size: 12, weight: .bold))
                        }
                        .offset(x: -8, y: 8)
                    }
                } else {
                    // Fallback to original image
                    Image(uiImage: processedImage.originalImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .frame(height: 209)
                        .padding(12)
                        .clipped()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 233)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(processedImage.isProcessing || processedImage.segmentedImage == nil)
    }
}

struct PhotoOutlineItem: View {
    let imageName: String?
    let uiImage: UIImage?
    let onTap: () -> Void
    
    init(imageName: String, onTap: @escaping () -> Void) {
        self.imageName = imageName
        self.uiImage = nil
        self.onTap = onTap
    }
    
    init(uiImage: UIImage, onTap: @escaping () -> Void) {
        self.imageName = nil
        self.uiImage = uiImage
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap) {
            Group {
                if let imageName = imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else if let uiImage = uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Color.gray
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 209)
            .padding(12)
            .background(Color(red: 28/255, green: 28/255, blue: 30/255))
            .clipped()
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(red: 69/255, green: 69/255, blue: 74/255), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PersonSelectorView(outlineOverlayImage: .constant(nil), cameraMode: .people)
}
