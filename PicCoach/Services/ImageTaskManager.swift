//
//  ImageTaskManager.swift
//  PicCoach
//
//  Created by Hoang Hai on 23/8/25.
//

import SwiftUI

final class ImageTaskManager: ObservableObject {
    static let shared = ImageTaskManager()
    private init() {}
    
    @Published var technicalityResults: [String: TechnicalityResult] = [:]  // task_id: result
    @Published var enhancedImages: [String: UIImage] = [:]                  // task_id: image
    
    @Published var lastUploadedPhoto: UIImage?
}

extension ImageTaskManager {
    
    func startTechnicalityTask(for image: UIImage) {
        lastUploadedPhoto = image
        Task.detached { [weak self] in
            do {
                // 1. POST the image, get task_id
                let response: TaskResponse = try await APIService.shared.postImageTask(endpoint: .technicalitySuggestion, image: image)
                
                let taskId = response.task_id
                print("✅ Technicality task started: \(taskId)")
                
                // 2. Poll for completion
                var statusResponse: TechnicalityStatus?
                repeat {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    statusResponse = try? await APIService.shared.getTechnicalityStatus(taskID: taskId)
                } while statusResponse?.status != "completed"
                
                if let result = statusResponse?.result {
                    await MainActor.run {
                        self?.technicalityResults[taskId] = result
                        print("📊 Technicality result ready for \(taskId)")
                    }
                }
            } catch {
                print("⚠️ Technicality task failed: \(error)")
            }
        }
    }
    
    func startEnhanceTask(for image: UIImage) {
        lastUploadedPhoto = image
        Task.detached { [weak self] in
            do {
                // 1. POST the image, get task_id
                let response: TaskResponse = try await APIService.shared.postImageTask(endpoint: .enhanceGeneration, image: image)
                let taskId = response.task_id
                print("✅ Enhance task started: \(taskId)")
                
                // 2. Poll until completion
                var enhancedImage: UIImage?
                repeat {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    enhancedImage = try? await APIService.shared.getEnhanceStatus(taskID: taskId)
                } while enhancedImage == nil
                
                if let finalImage = enhancedImage {
                    await MainActor.run {
                        self?.enhancedImages[taskId] = finalImage
                        print("🖼️ Enhanced image ready for \(taskId)")
                    }
                }
            } catch {
                print("⚠️ Enhance generation task failed: \(error)")
            }
        }
    }
}
