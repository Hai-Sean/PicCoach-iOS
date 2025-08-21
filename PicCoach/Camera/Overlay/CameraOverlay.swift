//
//  CameraOverlay.swift
//  PicCoach
//
//  Created by Hoang Hai on 22/8/25.
//

import SwiftUI

struct CameraOverlay: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let w = geo.size.width
                let h = geo.size.height
                let thirdW = w / 3
                let thirdH = h / 3
                
                // Vertical lines
                path.move(to: CGPoint(x: thirdW, y: 0))
                path.addLine(to: CGPoint(x: thirdW, y: h))
                
                path.move(to: CGPoint(x: 2 * thirdW, y: 0))
                path.addLine(to: CGPoint(x: 2 * thirdW, y: h))
                
                // Horizontal lines
                path.move(to: CGPoint(x: 0, y: thirdH))
                path.addLine(to: CGPoint(x: w, y: thirdH))
                
                path.move(to: CGPoint(x: 0, y: 2 * thirdH))
                path.addLine(to: CGPoint(x: w, y: 2 * thirdH))
            }
            .stroke(Color.white.opacity(0.5), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }
}
