//
//  APIService.swift
//  PicCoach
//
//  Created by Hoang Hai on 23/8/25.
//

import Foundation
import UIKit

enum APIEndpoint {
    case suggestion
    case segmentHuman
    case segmentObject
    case technicalitySuggestion
    
    var path: String {
        switch self {
        case .suggestion: return "/suggestion"
        case .segmentHuman: return "/segment/human"
        case .segmentObject: return "/segment/object"
        case .technicalitySuggestion: return "/image/technicality_suggestion"
        }
    }
}

class APIService {
    static let shared = APIService()
    private init() {}
    
    private let baseURL = "https://piccoach-be-1075160092468.asia-southeast1.run.app"
    
    // MARK: - JSON Request (like /suggestion)
    func postJSON<T: Codable, U: Codable>(
        endpoint: APIEndpoint,
        body: T,
        responseType: U.Type
    ) async throws -> U {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(U.self, from: data)
    }
    
    // MARK: - Multipart Request (file upload)
    func uploadFile(
        endpoint: APIEndpoint,
        image: UIImage,
        fieldName: String = "file"
    ) async throws -> String {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw URLError(.badURL)
        }
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        return String(data: data, encoding: .utf8) ?? ""
    }
}

