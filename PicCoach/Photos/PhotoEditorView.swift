//
//  PhotoEditorView.swift
//  PicCoach
//
//  Created by Hoang Hai on 23/8/25.
//

import SwiftUI

struct PhotoEditorView: View {
    @Environment(\.presentationMode) var presentationMode
    let photo: UIImage   // the photo passed in
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Top Bar
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
                .padding(.leading)
                
                Spacer()
                
                Text("ADJUST")
                    .foregroundColor(.white)
                    .font(.headline)
                
                Spacer()
                
                Button("Done") {
                    // done action
                }
                .foregroundColor(.yellow)
                .padding(.trailing)
            }
            .padding(.vertical, 10)
            .background(Color.black)
            
            // MARK: - Image Preview
            GeometryReader { geo in
                Color.black
                    .overlay(
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    )
            }
            
            // MARK: - Slider / Adjustment Controls
            VStack(spacing: 16) {
                Text("AUTO")
                    .foregroundColor(.white)
                    .font(.subheadline)
                
                Slider(value: .constant(0.5))
                    .padding(.horizontal)
                
                HStack(spacing: 30) {
                    Button(action: {}) { Image(systemName: "wand.and.stars") }
                    Button(action: {}) { Image(systemName: "circle.lefthalf.filled") }
                    Button(action: {}) { Image(systemName: "camera.filters") }
                }
                .font(.title2)
                .foregroundColor(.white)
            }
            .padding(.vertical)
            .background(Color.black)
            
            Divider()
                .background(Color.gray)
            
            // MARK: - Bottom Toolbar
            HStack {
                Spacer()
                VStack {
                    Image(systemName: "slider.horizontal.3")
                    Text("Adjust").font(.caption2)
                }
                Spacer()
                VStack {
                    Image(systemName: "circle.hexagongrid.fill")
                    Text("Filters").font(.caption2)
                }
                Spacer()
                VStack {
                    Image(systemName: "crop")
                    Text("Crop").font(.caption2)
                }
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .background(Color.black)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

