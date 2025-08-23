//
//  PersonSelectorView.swift
//  PicCoach
//
//  Created by AI Assistant on 21/8/25.
//

import SwiftUI

struct PersonSelectorView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedPersonCount = "1 Person"
    @State private var showDropdown = false
    
    let personOptions = ["1 Person"]
    
    var body: some View {
        ZStack {
        
            VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        ZStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .medium))
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                
                // Person Selection Dropdown
                VStack(spacing: 10) {
                    // Text Field Button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showDropdown.toggle()
                        }
                    }) {
                        HStack {
                            Text(selectedPersonCount)
                                .font(.custom("Geist", size: 14))
                                .fontWeight(.regular)
                                .foregroundColor(Color(red: 247/255, green: 247/255, blue: 248/255))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(Color(red: 247/255, green: 247/255, blue: 248/255))
                                .font(.system(size: 12, weight: .medium))
                                .rotationEffect(.degrees(showDropdown ? 180 : 0))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 2)
                        .frame(height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(red: 228/255, green: 255/255, blue: 90/255).opacity(0.05))
                                .stroke(Color(red: 249/255, green: 255/255, blue: 201/255), lineWidth: 1)
                        )
                    }
                    .overlay(
                        // Dropdown Menu - Absolute positioned
                        Group {
                            if showDropdown {
                                VStack(spacing: 0) {
                                    ForEach(personOptions, id: \.self) { option in
                                        Button(action: {
                                            selectedPersonCount = option
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                showDropdown = false
                                            }
                                        }) {
                                            HStack {
                                                Text(option)
                                                    .font(.custom("Geist", size: 14))
                                                    .fontWeight(option == selectedPersonCount ? .medium : .regular)
                                                    .foregroundColor(option == selectedPersonCount ? 
                                                        Color(red: 228/255, green: 255/255, blue: 90/255) : 
                                                        Color(red: 247/255, green: 247/255, blue: 248/255))
                                                Spacer()
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .frame(height: 56)
                                            .background(Color.clear)
                                        }
                                    }
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.1))
                                        .background(.ultraThinMaterial)
                                )
                                .offset(y: 50)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
                                    removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .top))
                                ))
                            }
                        }
                        , alignment: .topLeading
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .zIndex(1)
                
                // Photo Grid
                VStack(spacing: 16) {
                    // First row
                    HStack(spacing: 16) {
                        // Upload button
                        Button(action: {
                            // Handle upload action
                        }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 228/255, green: 255/255, blue: 90/255).opacity(0.05))
                                        .stroke(Color(red: 88/255, green: 105/255, blue: 30/255), lineWidth: 1)
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "plus")
                                        .foregroundColor(Color(red: 228/255, green: 255/255, blue: 90/255))
                                        .font(.system(size: 16, weight: .medium))
                                }
                                
                                Text("Upload")
                                    .font(.custom("Geist", size: 14))
                                    .fontWeight(.regular)
                                    .foregroundColor(Color(red: 228/255, green: 255/255, blue: 90/255))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 233)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(red: 228/255, green: 255/255, blue: 90/255).opacity(0.03))
                                    .stroke(Color(red: 69/255, green: 69/255, blue: 74/255), lineWidth: 1)
                            )
                        }
                        
                        PhotoOutlineItem(image: "sample_pose")
                    }
                
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
            }
        }
        .background(Color.black.opacity(0.8))
        .navigationBarHidden(true)
    }
}

struct PhotoOutlineItem: View {
    let image: String
    
    var body: some View {
        Image(image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity)
            .frame(height: 233)
            .clipped()
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(red: 69/255, green: 69/255, blue: 74/255), lineWidth: 1)
            )
    }
}

#Preview {
    PersonSelectorView()
}
