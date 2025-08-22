//
//  FilterControlsView.swift
//  PicCoach
//
//  Created by Hoang Hai on 23/8/25.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - FilterControlsView
struct FilterControlsView: View {
    let photo: UIImage
    
    // TODO: - refactor for smooth UI
    @Binding var selectedFilter: PhotoFilter?
    @Binding var filterOpacity: Double
    
    // cache for thumbnails
    @State private var thumbnails: [UUID: UIImage] = [:]
    
    var body: some View {
        VStack {
            // --- Preview with selected filter ---
            Image(uiImage: previewImage())
                .resizable()
                .scaledToFit()
                .padding()
            
            Divider().background(Color.white)
            
            // --- Selected Filter Title ---
            if let filterName = selectedFilter?.name {
                Text(filterName)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 4)
            }
            
            // --- Horizontal filter list ---
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(availableFilters) { filter in
                        Button {
                            selectedFilter = filter
                        } label: {
                            VStack {
                                if let thumb = thumbnails[filter.id] {
                                    Image(uiImage: thumb)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(selectedFilter?.id == filter.id ? Color.yellow : Color.clear, lineWidth: 2)
                                        )
                                } else {
                                    ProgressView()
                                        .frame(width: 60, height: 60)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
                .onAppear {
                    generateThumbnails()
                }
            }
            
            // --- Filter Opacity Slider ---
            if selectedFilter?.name != PhotoFilterType.original.rawValue {
                VStack {
                    Slider(value: $filterOpacity, in: 0...1, step: 0.05)
                        .padding(.horizontal)
                    Text("\(Int(filterOpacity * 100))%")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(height: 24)
            } else {
                Spacer()
                    .frame(height: 24)
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    // MARK: - Preview with current filter
    func previewImage() -> UIImage {
        guard let filter = selectedFilter else { return photo }
        
        let ciContext = CIContext()
        guard let ciImage = CIImage(image: photo),
              let output = filter.apply(ciImage, ciContext),
              let cgImage = ciContext.createCGImage(output, from: output.extent)
        else {
            return photo
        }
        
        let filteredImage = UIImage(cgImage: cgImage)
        return photo.blendImages(filtered: filteredImage, opacity: filterOpacity)
    }
    
    // MARK: - Generate thumbnails for filters
    private func generateThumbnails() {
        let ciContext = CIContext()
        let targetSize = CGSize(width: 60, height: 60)
        
        DispatchQueue.global(qos: .userInitiated).async {
            var results: [UUID: UIImage] = [:]
            for filter in availableFilters {
                if let ciImage = CIImage(image: photo),
                   let output = filter.apply(ciImage, ciContext),
                   let cgImage = ciContext.createCGImage(output, from: output.extent) {
                    
                    let uiImage = UIImage(cgImage: cgImage).resized(to: targetSize)
                    results[filter.id] = uiImage
                } else {
                    results[filter.id] = photo.resized(to: targetSize)
                }
            }
            
            DispatchQueue.main.async {
                thumbnails = results
            }
        }
    }
}
