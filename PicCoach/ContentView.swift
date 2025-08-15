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

    var body: some View {
        ZStack {
            CameraPreview(session: camera.session)
                .ignoresSafeArea()

            VStack {
                Spacer()

                ZStack {
                    // Bottom-left thumbnail
                    HStack {
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
                            }
                            .padding(.leading, 20)
                        } else {
                            Color.clear.frame(width: 60, height: 60)
                                .padding(.leading, 20)
                        }

                        Spacer()
                    }

                    // Center capture button
                    Button(action: { camera.takePhoto() }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 70, height: 70)
                            .overlay(Circle().stroke(Color.black, lineWidth: 2))
                    }
                }
                .padding(.bottom, 30)
            }
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
