//
//  PhotoPreviewView.swift
//  PicCoach
//
//  Created by Hoang Hai on 15/8/25.
//

import SwiftUI

struct PhotoPreviewView: View {
    var image: UIImage
    @Environment(\.dismiss) var dismiss
    @State private var offset = CGSize.zero
    @State private var isEditing = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()
                    .offset(y: offset.height)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                if gesture.translation.height > 0 {
                                    offset = gesture.translation
                                }
                            }
                            .onEnded { gesture in
                                if gesture.translation.height > 150 {
                                    dismiss()
                                } else {
                                    withAnimation(.spring()) {
                                        offset = .zero
                                    }
                                }
                            }
                    )
            }
            .toolbar {
                // Close (X) button on the left
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                // Edit button on the right (unchanged)
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isEditing = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationDestination(isPresented: $isEditing) {
                PhotoEditorView(photo: image)
            }
        }
    }
}
