//
//  ProcessedImageStorage.swift
//  PicCoach
//
//  Created by AI Assistant on 23/8/25.
//

import Foundation
import UIKit

// MARK: - Codable Models for Storage
struct StoredProcessedImage: Codable, Identifiable {
    let id: String
    let originalImagePath: String
    let segmentedImagePath: String?
    let isProcessing: Bool
    let error: String?
    let timestamp: Date
    let cameraMode: String
    
    init(from processedImage: ProcessedImage, cameraMode: CameraMode) {
        self.id = processedImage.id.uuidString
        self.originalImagePath = "original_\(processedImage.id.uuidString).jpg"
        self.segmentedImagePath = processedImage.segmentedImage != nil ? "segmented_\(processedImage.id.uuidString).jpg" : nil
        self.isProcessing = processedImage.isProcessing
        self.error = processedImage.error
        self.timestamp = Date()
        self.cameraMode = cameraMode.rawValue
    }
}

// MARK: - ProcessedImageStorage Service
class ProcessedImageStorage: ObservableObject {
    static let shared = ProcessedImageStorage()
    
    private let userDefaults = UserDefaults.standard
    private let fileManager = FileManager.default
    private let storageKey = "ProcessedImages"
    
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var imagesDirectory: URL {
        documentsDirectory.appendingPathComponent("ProcessedImages")
    }
    
    private init() {
        createDirectoryIfNeeded()
    }
    
    private func createDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: imagesDirectory.path) {
            try? fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Save Methods
    func saveProcessedImage(_ processedImage: ProcessedImage, cameraMode: CameraMode) {
        let storedImage = StoredProcessedImage(from: processedImage, cameraMode: cameraMode)
        
        // Save images to file system
        saveImageToFile(processedImage.originalImage, fileName: storedImage.originalImagePath)
        
        if let segmentedImage = processedImage.segmentedImage {
            saveImageToFile(segmentedImage, fileName: storedImage.segmentedImagePath!)
        }
        
        // Save metadata to UserDefaults
        var storedImages = loadStoredMetadata()
        
        // Remove existing entry if updating
        storedImages.removeAll { $0.id == storedImage.id }
        storedImages.append(storedImage)
        
        // Keep only the most recent 100 images to avoid excessive storage (increased from 50)
        if storedImages.count > 100 {
            let sortedImages = storedImages.sorted { $0.timestamp > $1.timestamp }
            let imagesToRemove = Array(sortedImages.dropFirst(100))
            
            // Remove old images from file system
            for imageToRemove in imagesToRemove {
                removeImageFromFile(fileName: imageToRemove.originalImagePath)
                if let segmentedPath = imageToRemove.segmentedImagePath {
                    removeImageFromFile(fileName: segmentedPath)
                }
            }
            
            storedImages = Array(sortedImages.prefix(100))
        }
        
        saveStoredMetadata(storedImages)
    }
    
    // Save all current processing images (called when app goes to background or view disappears)
    func saveAllProcessingImages(_ processedImages: [ProcessedImage], cameraMode: CameraMode) {
        print("💾 Saving all images including processing ones...")
        
        for image in processedImages {
            // Save all images, including those that are still processing
            saveProcessedImage(image, cameraMode: cameraMode)
        }
        
        print("✅ Saved \(processedImages.count) images to storage")
    }
    
    // MARK: - Load Methods
    func loadProcessedImages(for cameraMode: CameraMode) -> [ProcessedImage] {
        let storedImages = loadStoredMetadata()
        let filteredImages = storedImages.filter { $0.cameraMode == cameraMode.rawValue }
        
        let processedImages: [ProcessedImage] = filteredImages.compactMap { storedImage -> ProcessedImage? in
            guard let originalImage = loadImageFromFile(fileName: storedImage.originalImagePath) else {
                return nil
            }
            
            let segmentedImage = storedImage.segmentedImagePath != nil ? 
                loadImageFromFile(fileName: storedImage.segmentedImagePath!) : nil
            
            // Create ProcessedImage with explicit UUID
            let imageId = UUID(uuidString: storedImage.id) ?? UUID()
            return ProcessedImage(
                originalImage: originalImage,
                segmentedImage: segmentedImage,
                isProcessing: storedImage.isProcessing,
                error: storedImage.error,
                id: imageId
            )
        }
        
        // Sort: processing items first, then by timestamp (newest first)
        return processedImages.sorted { first, second in
            if first.isProcessing != second.isProcessing {
                return first.isProcessing // Processing items first
            }
            // For items with same processing status, maintain original order (based on timestamp)
            return false
        }
    }
    
    // Resume processing for any incomplete images
    func getProcessingImages(for cameraMode: CameraMode) -> [ProcessedImage] {
        let allImages = loadProcessedImages(for: cameraMode)
        return allImages.filter { $0.isProcessing }
    }
    
    // MARK: - Delete Methods
    func deleteProcessedImage(_ processedImage: ProcessedImage, cameraMode: CameraMode) {
        var storedImages = loadStoredMetadata()
        let imageId = processedImage.id.uuidString
        
        // Find and remove the stored image
        if let index = storedImages.firstIndex(where: { $0.id == imageId }) {
            let storedImage = storedImages[index]
            
            // Remove images from file system
            removeImageFromFile(fileName: storedImage.originalImagePath)
            if let segmentedPath = storedImage.segmentedImagePath {
                removeImageFromFile(fileName: segmentedPath)
            }
            
            // Remove from metadata
            storedImages.remove(at: index)
            saveStoredMetadata(storedImages)
        }
    }
    
    func clearAllProcessedImages() {
        let storedImages = loadStoredMetadata()
        
        // Remove all images from file system
        for storedImage in storedImages {
            removeImageFromFile(fileName: storedImage.originalImagePath)
            if let segmentedPath = storedImage.segmentedImagePath {
                removeImageFromFile(fileName: segmentedPath)
            }
        }
        
        // Clear metadata
        userDefaults.removeObject(forKey: storageKey)
    }
    
    // MARK: - Private Helper Methods
    private func saveImageToFile(_ image: UIImage, fileName: String) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let url = imagesDirectory.appendingPathComponent(fileName)
        try? data.write(to: url)
    }
    
    private func loadImageFromFile(fileName: String) -> UIImage? {
        let url = imagesDirectory.appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
    
    private func removeImageFromFile(fileName: String) {
        let url = imagesDirectory.appendingPathComponent(fileName)
        try? fileManager.removeItem(at: url)
    }
    
    private func loadStoredMetadata() -> [StoredProcessedImage] {
        guard let data = userDefaults.data(forKey: storageKey) else { return [] }
        return (try? JSONDecoder().decode([StoredProcessedImage].self, from: data)) ?? []
    }
    
    private func saveStoredMetadata(_ storedImages: [StoredProcessedImage]) {
        guard let data = try? JSONEncoder().encode(storedImages) else { return }
        userDefaults.set(data, forKey: storageKey)
    }
    
    // MARK: - Utility Methods
    func getStorageInfo() -> (count: Int, sizeInMB: Double, processingCount: Int) {
        let storedImages = loadStoredMetadata()
        let processingCount = storedImages.filter { $0.isProcessing }.count
        var totalSize: Int64 = 0
        
        for storedImage in storedImages {
            let originalUrl = imagesDirectory.appendingPathComponent(storedImage.originalImagePath)
            if let attributes = try? fileManager.attributesOfItem(atPath: originalUrl.path) {
                totalSize += attributes[.size] as? Int64 ?? 0
            }
            
            if let segmentedPath = storedImage.segmentedImagePath {
                let segmentedUrl = imagesDirectory.appendingPathComponent(segmentedPath)
                if let attributes = try? fileManager.attributesOfItem(atPath: segmentedUrl.path) {
                    totalSize += attributes[.size] as? Int64 ?? 0
                }
            }
        }
        
        let sizeInMB = Double(totalSize) / (1024 * 1024)
        return (storedImages.count, sizeInMB, processingCount)
    }
}
