//
//  PersonSelectorView.swift
//  PicCoach
//
//  Created by AI Assistant on 21/8/25.
//

import SwiftUI

struct PersonSelectorView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var outlineOverlayImage: UIImage?
    @State private var selectedPersonCount = "1 Person"
    @State private var showDropdown = false
    @State private var showingImagePicker = false
    @State private var uploadedImages: [UIImage] = []
    
    let personOptions = ["1 Person"]
    
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
                        
                        // Uploaded images
                        ForEach(Array(uploadedImages.enumerated()), id: \.offset) { index, image in
                            PhotoOutlineItem(uiImage: image) {
                                outlineOverlayImage = image
                                presentationMode.wrappedValue.dismiss()
                            }
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
                        uploadedImages.append(image)
                    }
                }
            ))
        }
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
    PersonSelectorView(outlineOverlayImage: .constant(nil))
}
