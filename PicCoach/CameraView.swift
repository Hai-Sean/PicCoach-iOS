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
    
    // Navigation state
    @State private var showPersonSelector = false
    @StateObject private var taskManager = ImageTaskManager.shared
    @State private var showTechnicalityPreview = false
    @State private var technicalityPreviewAdjustments: (brightness: Double, contrast: Double, saturation: Double, exposure: Double)?
    
    @State private var showEnhancedPreview = false
    @State private var enhancedPreviewImage: UIImage?
    
    private var hasTechnicalityResult: Bool {
        !taskManager.technicalityResults.isEmpty
    }
    
    private var hasEnhancedImage: Bool {
        !(taskManager.enhancedImages.first?.value == nil)
    }
    
    private var enhanceImage: UIImage? {
        taskManager.enhancedImages.first?.value
    }
    
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
                            
                            VStack(spacing: 16) {
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
                                
                                if hasTechnicalityResult {
                                    Button(action: {
                                        // Use the latest technicality result
                                        previewTSPhoto()
                                    }) {
                                        Text("TS")
                                            .font(.system(size: 14, weight: .bold))
                                            .frame(width: 40, height: 40)
                                            .background(Color.yellow.opacity(0.8))
                                            .foregroundColor(.black)
                                            .clipShape(Circle())
                                    }
                                    .padding()
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                    .animation(.easeInOut, value: hasTechnicalityResult)
                                }
                                
                                if hasEnhancedImage, let firstEnhanced = enhanceImage {
                                    Button(action: {
                                        enhancedPreviewImage = firstEnhanced
                                        showEnhancedPreview = true
                                    }) {
                                        Text("ENH")
                                            .font(.system(size: 14, weight: .bold))
                                            .frame(width: 40, height: 40)
                                            .background(Color.green.opacity(0.8))
                                            .foregroundColor(.black)
                                            .clipShape(Circle())
                                    }
                                    .padding()
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
                    showPersonSelector: $showPersonSelector,
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
        .fullScreenCover(isPresented: $showPersonSelector) {
            PersonSelectorView(outlineOverlayImage: $outlineOverlayImage, cameraMode: selectedCameraMode)
        }
        .fullScreenCover(isPresented: $showTechnicalityPreview) {
            if let adjustments = technicalityPreviewAdjustments,
               let lastPhoto = ImageTaskManager.shared.lastUploadedPhoto ?? lastLibraryPhoto {
                TechnicalityPreviewView(
                    originalImage: lastPhoto,
                    adjustments: adjustments
                )
            } else {
                // fallback if adjustments not ready
                Text("Loading...")
                    .font(.title)
                    .foregroundColor(.white)
                    .background(Color.black.edgesIgnoringSafeArea(.all))
            }
        }
        .fullScreenCover(isPresented: $showEnhancedPreview) {
            if let image = enhancedPreviewImage {
                EnhancedPreviewView(image: image)
            }
        }
    }
    
    func previewTSPhoto() {
        if let result = taskManager.technicalityResults.values.first {
            let adjustments = (
                brightness: Double(result.brightness),
                contrast: Double(result.contrast),
                saturation: Double(result.saturation),
                exposure: Double(result.exposure)
            )
            
            DispatchQueue.main.async {
                self.technicalityPreviewAdjustments = adjustments
                self.showTechnicalityPreview = true
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
