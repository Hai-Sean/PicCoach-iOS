//
//  WelcomeView.swift
//  PicCoach
//
//  Created by Hoang Hai on 22/8/25.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.black.opacity(0.9)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack {
                    Spacer().frame(height: 60) // top spacing
                    
                    // Title
                    HStack {
                        Text("Welcome to\nPicCoach")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Center image
                    Image("welcome_img")
                        .resizable()
                        .scaledToFit()
                    
                    Spacer()
                    
                    // Navigation button
                    NavigationLink(destination: CameraView()) {
                        Text("Get started")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#E4FF5A"))
                            .foregroundColor(.black)
                            .cornerRadius(12)
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer().frame(height: 40) // bottom spacing
                }
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
