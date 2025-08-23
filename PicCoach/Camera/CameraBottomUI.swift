//
//  CameraBottomUI.swift
//  PicCoach
//
//  Created on Camera bottom UI refactor
//

import SwiftUI

enum CameraMode: String, CaseIterable {
    case classic = "Classic"
    case people = "People"
    case product = "Product"
}

struct CameraBottomUI: View {
    @ObservedObject var camera: CameraModel
    @Binding var selectedCameraMode: CameraMode
    @Binding var showPreview: Bool
    @Binding var outlineOverlayEnabled: Bool
    @Binding var outlineOverlayOpacity: Double
    @Binding var outlineOverlayImage: UIImage?
    @Binding var outlineOverlayScale: CGFloat
    @Binding var outlineOverlayOffset: CGSize
    @Binding var outlineOverlayRotation: Double
    @Binding var showPersonSelector: Bool
    
    let lastLibraryPhoto: UIImage?
    let screenWidth: CGFloat
    
    var body: some View {
        VStack {
            Spacer()

            if outlineOverlayEnabled {
                HStack {
                    Spacer()
                    Button(action: {
                        showPersonSelector = true
                    }) {
                        Image("frame_person")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .cornerRadius(8) 
                    }
                    .padding(.trailing, 20)
                }
            }


            VStack {
                // Camera Modes - Scrollable
                ScrollView(.horizontal, showsIndicators: false) {
                    ScrollViewReader { proxy in
                        HStack(spacing: 20) {
                            // Add leading spacer to center first item
                            Spacer()
                                .frame(width: screenWidth / 2 - 60)
                            
                            ForEach(CameraMode.allCases, id: \.self) { mode in
                                                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedCameraMode = mode
                        // Auto-scroll to center the selected mode
                        proxy.scrollTo(mode, anchor: .center)
                        
                        // Enable OutlineOverlayControls for People and Product modes
                        if mode == .people || mode == .product {
                            outlineOverlayEnabled = true
                        } else if mode == .classic {
                            outlineOverlayEnabled = false
                        }
                    }
                }) {
                                    Text(mode.rawValue)
                                        .font(.system(size: selectedCameraMode == mode ? 16 : 14, weight: selectedCameraMode == mode ? .semibold : .medium))
                                        .foregroundColor(selectedCameraMode == mode ? Color(red: 0.89, green: 1.0, blue: 0.35) : Color(red: 0.98, green: 1.0, blue: 0.79))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(
                                            selectedCameraMode == mode 
                                                ? Color(red: 0.89, green: 1.0, blue: 0.35).opacity(0.15)
                                                : Color.clear
                                        )
                                        .cornerRadius(selectedCameraMode == mode ? 12 : 8)
                                        .scaleEffect(selectedCameraMode == mode ? 1.05 : 1.0)
                                }
                                .id(mode)
                            }
                            
                            // Add trailing spacer to center last item
                            Spacer()
                                .frame(width: screenWidth / 2 - 60)
                        }
                        .onAppear {
                            // Center the initially selected mode
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                proxy.scrollTo(selectedCameraMode, anchor: .center)
                            }
                        }
                    }
                }
                .padding(.top, 16)
                
                // Outline Overlay Controls - Show for People and Product modes
                if selectedCameraMode == .people || selectedCameraMode == .product {
                    OutlineOverlayControls(
                        isEnabled: $outlineOverlayEnabled,
                        opacity: $outlineOverlayOpacity,
                        selectedImage: $outlineOverlayImage,
                        scale: $outlineOverlayScale,
                        offset: $outlineOverlayOffset,
                        rotation: $outlineOverlayRotation
                    )
                    // .transition(.move(edge: .top).combined(with: .opacity))
                }
                Spacer()
                HStack {
                    // Image preview thumbnail (left)
                    if let image = camera.lastPhoto ?? lastLibraryPhoto {
                        Button {
                            camera.lastPhoto = image
                            showPreview = true
                        } label: {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipped()
                                .cornerRadius(8)
                                .shadow(radius: 3)
                                .padding(.leading, 20)
                        }
                    } else {
                        Color.gray
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.leading, 20)
                    }
                    
                    Spacer()
                    
                    // Capture button (center)
                    Button(action: {
                        camera.takePhoto()
                    }) {
                        // Shutter button with circle in circle
                        ZStack {
                            // Outer ring
                            Circle()
                                .stroke(Color.white, lineWidth: 5)  // ring outline
                                .frame(width: 60, height: 60)
                            
                            // Inner circle
                            Circle()
                                .fill(Color.white)
                                .frame(width: 50, height: 50)
                        }
                    }
                    
                    Spacer()
                    
                    // --- Switch camera button (right side) ---
                    Button(action: {
                        camera.switchCamera()
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .padding(15)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())  
                    }
                    .padding(.trailing, 20)
                }.padding(.bottom, 30)
                
            }
            .frame(height: 230)
            .padding(.horizontal, 0)
            .padding(.vertical, 20)
            .background(Color(red: 0.08, green: 0.08, blue: 0.08).opacity(0.8))
        }.ignoresSafeArea(.all)
    }
}
