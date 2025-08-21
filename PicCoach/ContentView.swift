//
//  ContentView.swift
//  PicCoach
//
//  Created by Hoang Hai on 15/8/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var camera = CameraModel()
    @State private var showPreview = false
    @StateObject var motion = MotionManager()
    @State private var rollAngle: CGFloat = 0.0
    @State private var capturedImage: UIImage? = nil
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                
                // --- Top reserved area (e.g. 15%) ---
                Color.black
                    .opacity(0.8)
                    .frame(height: geo.size.height * 0.15)
                    .overlay(
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
                }
                
                // --- Bottom UI area (15%) ---
                VStack {
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
                .frame(height: geo.size.height * 0.20)
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

#Preview {
    ContentView()
}
