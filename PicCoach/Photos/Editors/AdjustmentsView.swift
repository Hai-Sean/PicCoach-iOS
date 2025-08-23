//
//  AdjustmentsView.swift
//  PicCoach
//
//  Created by Hoang Hai on 22/8/25.
//

import SwiftUI

enum AdjustmentType: String, CaseIterable {
    case exposure = "Exposure"
    case brightness = "Brightness"
    case contrast = "Contrast"
    case saturation = "Saturation"

    var icon: String {
        switch self {
        case .exposure:   return "sun.max"
        case .brightness: return "light.max"
        case .contrast:   return "circle.lefthalf.filled"
        case .saturation: return "drop"
        }
    }

    var range: ClosedRange<Double> {
        switch self {
        case .exposure:   return -2...2
        case .brightness: return -1...1
        case .contrast:   return 0.5...1.5
        case .saturation: return 0...2
        }
    }

    var defaultValue: Double {
        switch self {
        case .exposure:   return 0
        case .brightness: return 0
        case .contrast:   return 1
        case .saturation: return 1
        }
    }
}

struct AdjustmentsView: View {
    @Binding var exposure: Double
    @Binding var brightness: Double
    @Binding var contrast: Double
    @Binding var saturation: Double
    
    @State private var selectedAdjustment: AdjustmentType = .exposure
    
    init(exposure: Binding<Double>, brightness: Binding<Double>, contrast: Binding<Double>, saturation: Binding<Double>) {
        self._exposure = exposure
        self._brightness = brightness
        self._contrast = contrast
        self._saturation = saturation
        
        // 👇 Customize UISlider (used by SwiftUI's Slider)
        let thumbImage = UIImage(systemName: "circle.fill")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
            .resized(to: CGSize(width: 14, height: 14)) // smaller circle
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }

    var body: some View {
        VStack(spacing: 12) {
            // Line 1: Title
            Text(selectedAdjustment.rawValue)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 8)
            
            // Line 2: Horizontal picker with icons
            HStack(spacing: 16) {
                ForEach(AdjustmentType.allCases, id: \.self) { type in
                    VStack {
                        Image(systemName: type.icon)
                            .font(.system(size: 22))
                            .foregroundColor(type == selectedAdjustment ? .yellow : .white)
                            .onTapGesture { selectedAdjustment = type }

                        // indicator dot
                        Circle()
                            .fill(type == selectedAdjustment ? Color.yellow : Color.clear)
                            .frame(width: 6, height: 6)
                    }
                }
            }

            // Line 3: Single slider for selected adjustment
            Slider(value: binding(for: selectedAdjustment),
                   in: selectedAdjustment.range)
                .accentColor(.yellow)
                .padding(.horizontal)
        }
        .background(Color.black.opacity(0.6))
        // --- Reset button in the top-right
        .overlay(alignment: .topTrailing) {
            if isDirty {
                Button(action: resetAll) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.gray.opacity(0.7))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(.trailing, 10)
                .padding(.top, 8)
            }
        }
    }

    // MARK: - Helpers

    private func binding(for type: AdjustmentType) -> Binding<Double> {
        switch type {
        case .exposure:   return $exposure
        case .brightness: return $brightness
        case .contrast:   return $contrast
        case .saturation: return $saturation
        }
    }

    private func resetAll() {
        withAnimation(.easeInOut(duration: 0.2)) {
            exposure = AdjustmentType.exposure.defaultValue
            brightness = AdjustmentType.brightness.defaultValue
            contrast = AdjustmentType.contrast.defaultValue
            saturation = AdjustmentType.saturation.defaultValue
        }
    }

    // Hide reset button when everything is at defaults
    private var isDirty: Bool {
        !isApproximately(exposure, AdjustmentType.exposure.defaultValue) ||
        !isApproximately(brightness, AdjustmentType.brightness.defaultValue) ||
        !isApproximately(contrast, AdjustmentType.contrast.defaultValue) ||
        !isApproximately(saturation, AdjustmentType.saturation.defaultValue)
    }

    private func isApproximately(_ a: Double, _ b: Double, eps: Double = 0.0001) -> Bool {
        abs(a - b) < eps
    }
}
