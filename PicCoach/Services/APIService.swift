//
// APIService.swift
// PicCoach
//
// Created by Hoang Hai on 23/8/25.
//
import Foundation
import UIKit
enum APIEndpoint {
  case segmentHuman
  case segmentObject
  case technicalitySuggestion
  case enhaceGeneration
  var path: String {
    switch self {
    case .segmentHuman: return "/segment/human"
    case .segmentObject: return "/segment/object"
    case .technicalitySuggestion: return "/image/technicality_suggestion"
    case .enhaceGeneration: return "image/enhace_generation"
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
}
extension APIService {
  func uploadFileAsImage(
    endpoint: APIEndpoint,
    image: UIImage,
    fieldName: String = "file",
    imageUrl: String = "" // optional field for backend
  ) async throws -> UIImage {
    guard let url = URL(string: baseURL + endpoint.path) else {
      throw URLError(.badURL)
    }
    let boundary = UUID().uuidString
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    var body = Data()
    // Add file
    if let imageData = image.jpegData(compressionQuality: 0.8) {
      body.append("--\(boundary)\r\n".data(using: .utf8)!)
      body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
      body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
      body.append(imageData)
      body.append("\r\n".data(using: .utf8)!)
    }
    // Add optional image_url
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"image_url\"\r\n\r\n".data(using: .utf8)!)
    body.append("\(imageUrl)\r\n".data(using: .utf8)!)
    // End boundary
    body.append("--\(boundary)--\r\n".data(using: .utf8)!)
    request.httpBody = body
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }
    guard 200..<300 ~= httpResponse.statusCode else {
      print("Server returned HTTP \(httpResponse.statusCode): \(String(data: data, encoding: .utf8) ?? "")")
      throw URLError(.badServerResponse)
    }
    // Convert response Data to String
    if let responseStr = String(data: data, encoding: .utf8) {
      // Remove prefix "b'" and suffix "'" if present
      let trimmed = responseStr
        .trimmingCharacters(in: CharacterSet(charactersIn: "b'"))
        .replacingOccurrences(of: "\\n", with: "")
        .replacingOccurrences(of: "\\", with: "")
      // Convert hex-like string to Data
      if let imageData = Data(base64Encoded: trimmed) {
        guard let outputImage = UIImage(data: imageData) else {
          throw URLError(.cannotDecodeContentData)
        }
        return outputImage
      } else {
        throw URLError(.cannotDecodeContentData)
      }
    } else {
      guard let outputImage = UIImage(data: data) else {
        throw URLError(.cannotDecodeContentData)
      }
      return outputImage
    }
  }
}