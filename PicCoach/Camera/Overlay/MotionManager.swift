//
//  MotionManager.swift
//  PicCoach
//
//  Created by Hoang Hai on 22/8/25.
//

import CoreMotion
import SwiftUI

class MotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    @Published var roll: CGFloat = 0
    
    init() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.05 // 20 fps
            motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
                if let attitude = motion?.attitude {
                    // Roll in degrees (−180...180)
                    let rollDegrees = attitude.roll * 180 / .pi
                    // Smooth with animation to avoid jitter
                    withAnimation(.easeInOut(duration: 0.1)) {
                        self.roll = CGFloat(rollDegrees)
                    }
                }
            }
        }
    }
}
