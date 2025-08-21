//
//  CameraModel.swift
//  PicCoach
//
//  Created by Hoang Hai on 15/8/25.
//

import AVFoundation
import Photos
import UIKit

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var session = AVCaptureSession()
    @Published var lastPhoto: UIImage? // NEW: last captured image

    private var photoOutput = AVCapturePhotoOutput()

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

    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
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
            }
            
            session.commitConfiguration()
        }
    }

}
