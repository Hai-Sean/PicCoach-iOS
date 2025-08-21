//
//  CameraModel.swift
//  PicCoach
//
//  Created by Hoang Hai on 15/8/25.
//

import AVFoundation
import Photos
import UIKit
import SwiftUI

enum FlashMode: CaseIterable {
    case auto, on, off
}

enum AspectRatio: String {
    case fourThirds = "4:3"
    case oneOne = "1:1"
    case widescreen = "16:9"
}

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var session = AVCaptureSession()
    @Published var lastPhoto: UIImage? // NEW: last captured image
    @Published var flashMode: FlashMode = .auto
    @Published var timerSeconds: Int = 0       // user’s choice (0/3/10)
    @Published var countdown: Int = 0          // live countdown value
    @Published var aspectRatio: AspectRatio = .fourThirds
    @Published var zoomFactor: CGFloat = 1.0
    @Published var isUsingFrontCamera: Bool = false

    private var photoOutput = AVCapturePhotoOutput()
    private var countdownTimer: Timer?
    
    var aspectRatioValue: CGFloat {
        switch aspectRatio {
        case .fourThirds: return 4.0 / 3.0
        case .oneOne: return 1.0
        case .widescreen: return 16.0 / 9.0
        }
    }

    override init() {
        super.init()
        setupSession()
    }

    func setupSession() {
        session.beginConfiguration()

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else { return }

        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(photoOutput) { session.addOutput(photoOutput) }

        session.commitConfiguration()
        session.startRunning()
    }

    // MARK: - Taking photo with countdown
    func takePhoto() {
        if timerSeconds > 0 {
            startCountdownAndCapture()
        } else {
            captureNow()
        }
    }
    
    private func startCountdownAndCapture() {
        countdown = timerSeconds
        countdownTimer?.invalidate()
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            if self.countdown > 1 {
                self.countdown -= 1
            } else {
                timer.invalidate()
                self.countdown = 0
                self.captureNow()
                // Reset timer setting back to 0s after shot
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.timerSeconds = 0
                }
            }
        }
    }
    
    private func captureNow() {
        let settings = AVCapturePhotoSettings()
        switch flashMode {
        case .auto: settings.flashMode = .auto
        case .on: settings.flashMode = .on
        case .off: settings.flashMode = .off
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }

        DispatchQueue.main.async {
            self.lastPhoto = image // Save for thumbnail
        }

        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
    }
    
    func switchCamera() {
        if let currentInput = session.inputs.first as? AVCaptureDeviceInput {
            session.beginConfiguration()
            session.removeInput(currentInput)
            
            let newPosition: AVCaptureDevice.Position =
                currentInput.device.position == .back ? .front : .back
            
            if let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
               let newInput = try? AVCaptureDeviceInput(device: newDevice),
               session.canAddInput(newInput) {
                session.addInput(newInput)
                
                // ✅ Update state
                isUsingFrontCamera = (newPosition == .front)
                
                // ✅ Reset zoom if switched back to rear
                if !isUsingFrontCamera {
                    zoomFactor = 1.0
                    applyZoom()
                }
            }
            
            session.commitConfiguration()
        }
    }
    
    // Flash control
    func toggleFlashMode() {
        switch flashMode {
        case .auto: flashMode = .on
        case .on: flashMode = .off
        case .off: flashMode = .auto
        }
    }
    
    var flashModeIcon: String {
        switch flashMode {
        case .auto: return "bolt.badge.a"
        case .on: return "bolt.fill"
        case .off: return "bolt.slash.fill"
        }
    }
    
    // Timer control
    func cycleTimer() {
        if timerSeconds == 0 { timerSeconds = 3 }
        else if timerSeconds == 3 { timerSeconds = 10 }
        else { timerSeconds = 0 }
    }
    var timerText: String {
        countdown > 0 ? "\(countdown)s" : (timerSeconds == 0 ? "0s" : "\(timerSeconds)s")
    }
    
    // Aspect ratio
    func cycleAspectRatio() {
        if aspectRatio == .fourThirds { aspectRatio = .oneOne }
        else if aspectRatio == .oneOne { aspectRatio = .widescreen }
        else { aspectRatio = .fourThirds }
        
        // TODO: Adjust AVCaptureVideoPreviewLayer accordingly
    }
    var aspectText: String { aspectRatio.rawValue }
    
    // Zoom
    func cycleZoom() {
        if zoomFactor == 1.0 { zoomFactor = 2.0 }
        else if zoomFactor == 2.0 { zoomFactor = 3.0 }
        else { zoomFactor = 1.0 }
        
        applyZoom()
    }
    var zoomText: String { "x\(zoomFactor)" }
    
    private func applyZoom() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        try? device.lockForConfiguration()
        device.videoZoomFactor = zoomFactor
        device.unlockForConfiguration()
    }
    
    func topBarHeight(for aspect: AspectRatio, in geo: GeometryProxy) -> CGFloat {
        switch aspect {
        case .fourThirds:
            return (geo.size.height - geo.size.width * (4.0/3.0)) * 0.5
        case .oneOne:
            return (geo.size.height - geo.size.width) * 3.0/5.0
        case .widescreen:
            return (geo.size.height - geo.size.width * (16.0/9.0)) * 4.0/5.0
        }
    }
    
    func cameraHeight(for aspect: AspectRatio, in geo: GeometryProxy) -> CGFloat {
        switch aspect {
        case .fourThirds:
            return geo.size.width * (4.0/3.0)
        case .oneOne:
            return geo.size.width
        case .widescreen:
            return geo.size.width * (16.0/9.0)
        }
    }
}
