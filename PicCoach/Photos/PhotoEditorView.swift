//
//  PhotoEditorView.swift
//  PicCoach
//
//  Created by Hoang Hai on 23/8/25.
//

import SwiftUI
import PhotosUI

struct PhotoEditorView: View {
    @Environment(\.dismiss) private var dismiss
    
    var photo: UIImage
    
    enum EditorTab {
        case adjust, filter, crop
    }
    
    @State private var selectedTab: EditorTab = .adjust
    
    // Adjustment states
    @State private var exposure: Double = 0.0
    @State private var brightness: Double = 0.0
    @State private var contrast: Double = 1.0
    @State private var saturation: Double = 1.0
    
    @State private var selectedFilter: PhotoFilter? = availableFilters.first
    @State private var opacity: Double = 1.0
    
    @State private var workingImage: UIImage

    init(photo: UIImage) {
        self.photo = photo
        _workingImage = State(initialValue: photo)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // --- Top Bar ---
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.white)
                
                Spacer()
                
                Text("Adjust")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Done") {
                    saveToPhotos()
                }
                .foregroundColor(.yellow)
            }
            .padding()
            .background(Color.black.opacity(0.9))
            
            Divider()
            
            // --- Main Editor Area ---
            ZStack {
                Color.black.ignoresSafeArea()
                
                if selectedTab == .adjust {
                    AdjustControlsView(
                        photo: photo,
                        exposure: $exposure,
                        brightness: $brightness,
                        contrast: $contrast,
                        saturation: $saturation
                    )
                } else if selectedTab == .filter {
                    FilterControlsView(
                        photo: workingImage,
                        selectedFilter: $selectedFilter,
                        filterOpacity: $opacity
                    )
                } else {
                    Image(uiImage: workingImage)
                        .resizable()
                        .scaledToFit()
                        .padding()
                }
            }
            
            Divider()
            
            // --- Bottom Tab Bar ---
            HStack(spacing: 40) {
                tabButton(icon: "slider.horizontal.3", title: "Adjust", tab: .adjust)
                tabButton(icon: "wand.and.stars", title: "Filter", tab: .filter)
                tabButton(icon: "crop", title: "Crop", tab: .crop)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color.black.opacity(0.9))
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Tab Button
    private func tabButton(icon: String, title: String, tab: EditorTab) -> some View {
        Button {
            // TODO: - handle sync working image between tabs
//            if tab != .adjust {
//                // Apply adjustments to workingImage before leaving Adjust
//                if let adjusted = photo.applyingAdjustments(
//                    exposure: exposure,
//                    brightness: brightness,
//                    contrast: contrast,
//                    saturation: saturation
//                ) {
//                    workingImage = adjusted
//                }
//            }
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(selectedTab == tab ? .yellow : .gray)
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(selectedTab == tab ? .white : .gray)
            }
        }
    }
    
    // MARK: - Generate final image
    private func finalImage() -> UIImage {
        var output: UIImage = photo
        
        // Apply adjustments
        if let adjusted = photo.applyingAdjustments(
            exposure: exposure,
            brightness: brightness,
            contrast: contrast,
            saturation: saturation
        ) {
            output = adjusted
        }
        
        // Apply filter (with opacity blend)
        if selectedTab == .filter {
            output = getFilterdImage(selectedFilter: selectedFilter)
        }
        
        return output
    }

    // MARK: - Save to Photos
    private func saveToPhotos() {
        let imageToSave = finalImage()
        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
        dismiss()
    }

    private func getFilterdImage(selectedFilter: PhotoFilter?) -> UIImage {
        guard let filter = selectedFilter else { return photo }
        
        let ciContext = CIContext()
        guard let ciImage = CIImage(image: photo),
              let output = filter.apply(ciImage, ciContext),
              let cgImage = ciContext.createCGImage(output, from: output.extent)
        else {
            return photo
        }
        
        let filteredImage = UIImage(cgImage: cgImage)
        return photo.blendImages(filtered: filteredImage, opacity: opacity)
    }
}
