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
    
    var body: some View {
        return WelcomeView()
    }
}

#Preview {
    ContentView()
}
