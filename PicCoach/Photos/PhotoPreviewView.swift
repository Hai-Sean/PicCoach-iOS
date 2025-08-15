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

    var body: some View {
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
                            // Track vertical drag only
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
    }
}

