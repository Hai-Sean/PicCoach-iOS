//
// BalanceLine.swift
// PicCoach
//
// Created by Hoang Hai on 22/8/25.
//

import SwiftUI

struct BalanceLine: View {
    var rollAngle: CGFloat
    
    // thresholds
    private let visibleThreshold: CGFloat = 15.0   // show within ±20°
    private let levelThreshold: CGFloat = 2.0      // yellow when within ±2°
    
    var body: some View {
        GeometryReader { geo in
            let centerY = geo.size.height / 2
            let leftX: CGFloat = geo.size.width * 1/3
            let rightX: CGFloat = geo.size.width * 2/3
            let tickLength: CGFloat = geo.size.width * 0.05
            let centerLength: CGFloat = geo.size.width * 1/3
            
            ZStack {
                if isLevel {
                    // --- Single straight yellow line when balanced ---
                    Path { path in
                        path.move(to: CGPoint(x: leftX - tickLength, y: centerY))
                        path.addLine(to: CGPoint(x: rightX + tickLength, y: centerY))
                    }
                    .stroke(Color.yellow, lineWidth: 1)
                    
                } else {
                    // --- Fixed left tick ---
                    Path { path in
                        path.move(to: CGPoint(x: leftX - tickLength, y: centerY))
                        path.addLine(to: CGPoint(x: leftX + tickLength, y: centerY))
                    }
                    .stroke(Color.white, lineWidth: 1)
                    
                    // --- Fixed right tick ---
                    Path { path in
                        path.move(to: CGPoint(x: rightX - tickLength, y: centerY))
                        path.addLine(to: CGPoint(x: rightX + tickLength, y: centerY))
                    }
                    .stroke(Color.white, lineWidth: 1)
                    
                    // --- Rotating center line ---
                    Path { path in
                        let half = centerLength / 2
                        path.move(to: CGPoint(x: geo.size.width/2 - half, y: centerY))
                        path.addLine(to: CGPoint(x: geo.size.width/2 + half, y: centerY))
                    }
                    .stroke(Color.white, lineWidth: 1)
                    .rotationEffect(.degrees(Double(rollAngle)))
                }
            }
            .opacity(abs(rollAngle) <= visibleThreshold ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.18), value: rollAngle)
        }
        .allowsHitTesting(false)
    }
    
    private var isLevel: Bool {
        abs(rollAngle) <= levelThreshold
    }
}

struct BalanceLine_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            ZStack { Color.black.ignoresSafeArea(); BalanceLine(rollAngle: 0) }
                .previewDisplayName("Level → Single Yellow Line")
            
            ZStack { Color.black.ignoresSafeArea(); BalanceLine(rollAngle: 5) }
                .previewDisplayName("Tilted → 3 Lines")
        }
        .previewLayout(.fixed(width: 375, height: 812))
    }
}
