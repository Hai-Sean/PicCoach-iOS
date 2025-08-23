//
//  CameraView.swift
//  PicCoach
//
//  Created by Hoang Hai on 22/8/25.
//

import SwiftUI
import Photos

struct CameraView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var camera = CameraModel()
    @State private var showPreview = false
    @StateObject var motion = MotionManager()
    @State private var lastLibraryPhoto: UIImage?
    
    // Outline Overlay state
    @State private var outlineOverlayEnabled = false
    @State private var outlineOverlayOpacity: Double = 0.5
    @State private var outlineOverlayImage: UIImage?
    @State private var outlineOverlayScale: CGFloat = 1.0
    @State private var outlineOverlayOffset = CGSize.zero
    @State private var outlineOverlayRotation: Double = 0.0
    
    // Camera modes state
    @State private var selectedCameraMode: CameraMode = .classic
    

    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 0) {
                    Spacer()
                    
                    // --- Camera preview area ---
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
                                        .font(.system(size: 20))
                                        .frame(width: 40, height: 40)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }

                                // Timer button
                                Button(action: {
                                    camera.cycleTimer()
                                }) {
                                    if camera.timerSeconds == 0 && camera.countdown == 0 {
                                        Image("timer")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 25, height: 25)
                                            .foregroundColor(.white)
                                            .frame(width: 40, height: 40)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Circle())
                                    } else {
                                        Text(camera.timerText)
                                            .foregroundColor(.white)
                                            .font(.system(size: 16, weight: .bold))
                                            .frame(width: 40, height: 40)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Circle())
                                    }
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
                            }
                            
                            Spacer()
                        }
                    }
                    .frame(height: camera.cameraHeight(for: camera.aspectRatio, in: geo))

                    Spacer()
                }
                .background(Color(red: 0.08, green: 0.08, blue: 0.08).opacity(0.8))
                .edgesIgnoringSafeArea(.all)

                // --- Bottom UI area ---
                CameraBottomUI(
                    camera: camera,
                    selectedCameraMode: $selectedCameraMode,
                    showPreview: $showPreview,
                    outlineOverlayEnabled: $outlineOverlayEnabled,
                    outlineOverlayOpacity: $outlineOverlayOpacity,
                    outlineOverlayImage: $outlineOverlayImage,
                    outlineOverlayScale: $outlineOverlayScale,
                    outlineOverlayOffset: $outlineOverlayOffset,
                    outlineOverlayRotation: $outlineOverlayRotation,
                    lastLibraryPhoto: lastLibraryPhoto,
                    screenWidth: geo.size.width
                )

            }
        }
        .onAppear {
            fetchLastLibraryPhoto()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()   // <-- pops NavigationLink
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium))
                }
            }
        }
        .fullScreenCover(isPresented: $showPreview) {
            if let image = camera.lastPhoto {
                PhotoPreviewView(image: image)
            }
        }
    }
    
    func fetchLastLibraryPhoto() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        guard let asset = assets.firstObject else { return }
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        options.resizeMode = .exact
        
        let targetSize = CGSize(width: 200, height: 200)
        
        manager.requestImage(for: asset,
                             targetSize: targetSize,
                             contentMode: .aspectFill,
                             options: options) { image, _ in
            if let image = image {
                DispatchQueue.main.async {
                    self.lastLibraryPhoto = image
                }
            }
        }
    }
}
