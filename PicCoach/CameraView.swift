//
//  CameraView.swift
//  PicCoach
//
//  Created by Hoang Hai on 22/8/25.
//

import SwiftUI

struct CameraView: View {
    @StateObject var camera = CameraModel()
    @State private var showPreview = false
    @StateObject var motion = MotionManager()
    
    // Outline Overlay state
    @State private var outlineOverlayEnabled = false
    @State private var outlineOverlayOpacity: Double = 0.5
    @State private var outlineOverlayImage: UIImage?
    @State private var outlineOverlayScale: CGFloat = 1.0
    @State private var outlineOverlayOffset = CGSize.zero
    @State private var outlineOverlayRotation: Double = 0.0
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                
                // --- Top reserved area (e.g. 15%) ---
                Color.black
                    .opacity(0.8)
                    .frame(height: camera.topBarHeight(for: camera.aspectRatio, in: geo))
                    .overlay(
                        // TODO: - Add top quick action here
                        Text("Top UI") // placeholder
                            .foregroundColor(.white)
                    )
                
                // --- Camera preview area (70%) ---
                ZStack {
                    CameraPreview(session: camera.session)
                        .ignoresSafeArea()
                    
                    // Grid lines (optional, keep if you want rule of thirds)
                    CameraOverlay()
                        .opacity(0.5)
                    
                    // Balance line like iPhone camera
                    BalanceLine(rollAngle: motion.roll)
                    
                    // Outline Overlay
                    OutlineOverlay(
                        isEnabled: $outlineOverlayEnabled,
                        opacity: $outlineOverlayOpacity,
                        selectedImage: $outlineOverlayImage,
                        scale: $outlineOverlayScale,
                        offset: $outlineOverlayOffset,
                        rotation: $outlineOverlayRotation
                    )
                    
                    // --- Left control bar ---
                    HStack {
                        Spacer()
                            .frame(width: 20)
                        
                        VStack(spacing: 25) {
                            // Flash button
                            Button(action: {
                                camera.toggleFlashMode()
                            }) {
                                Image(systemName: camera.flashModeIcon)
                                    .foregroundColor(.white)
                                    .font(.system(size: 22))
                                    .frame(width: 40, height: 40)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                            }

                            // Timer button
                            Button(action: {
                                camera.cycleTimer()
                            }) {
                                Text(camera.timerText)
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .bold))
                                    .frame(width: 40, height: 40)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                            }

                            // Aspect ratio button
                            Button(action: {
                                camera.cycleAspectRatio()
                            }) {
                                Text(camera.aspectText)
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .bold))
                                    .frame(width: 40, height: 40)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                            }

                            // Zoom button
                            if !camera.isUsingFrontCamera {
                                Button(action: { camera.cycleZoom() }) {
                                    Text(camera.zoomText)
                                        .foregroundColor(.white)
                                        .font(.system(size: 14, weight: .bold))
                                        .frame(width: 40, height: 40)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }
                            }
                            
                            // Outline Overlay quick toggle
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    outlineOverlayEnabled.toggle()
                                }
                            }) {
                                Image(systemName: outlineOverlayEnabled ? "square.on.square.fill" : "square.on.square")
                                    .foregroundColor(outlineOverlayEnabled ? .blue : .white)
                                    .font(.system(size: 18))
                                    .frame(width: 40, height: 40)
                                    .background(outlineOverlayEnabled ? Color.blue.opacity(0.3) : Color.black.opacity(0.6))
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(outlineOverlayEnabled ? Color.blue : Color.clear, lineWidth: 2)
                                    )
                            }
                        }
                        
                        Spacer()
                    }
                }
                .frame(height: camera.cameraHeight(for: camera.aspectRatio, in: geo))


                
                // --- Bottom UI area (15%) ---
                VStack {
                    // Outline Overlay Controls
                    if outlineOverlayEnabled {
                        OutlineOverlayControls(
                            isEnabled: $outlineOverlayEnabled,
                            opacity: $outlineOverlayOpacity,
                            selectedImage: $outlineOverlayImage,
                            scale: $outlineOverlayScale,
                            offset: $outlineOverlayOffset,
                            rotation: $outlineOverlayRotation
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    HStack {
                        // Image preview thumbnail (left)
                        if let image = camera.lastPhoto {
                            Button {
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
                    }
                    .frame(height: 90)
                 
                    Spacer()
                }
                .background(Color.black.opacity(0.8))
            }
            .edgesIgnoringSafeArea(.all)
        }
        .fullScreenCover(isPresented: $showPreview) {
            if let image = camera.lastPhoto {
                PhotoPreviewView(image: image)
            }
        }
    }
}
