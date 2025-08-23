import Foundation
import UIKit

// MARK: - Endpoint
enum APIEndpoint {
    case segmentHuman
    case segmentObject
    case technicalitySuggestion
    case enhanceGeneration
    case technicalityStatus(taskID: String)
    case enhanceStatus(taskID: String)
    
    var path: String {
        switch self {
        case .segmentHuman: return "/segment/human"
        case .segmentObject: return "/segment/object"
        case .technicalitySuggestion: return "/image/technicality_suggestion"
        case .enhanceGeneration: return "/image/enhance_generation"
        case .technicalityStatus(let taskID): return "/image/technicality_suggestion/status/\(taskID)"
        case .enhanceStatus(let taskID): return "/image/enhance_generation/status/\(taskID)"
        }
    }
}

// MARK: - Task Response
struct TaskResponse: Codable {
    let task_id: String
    let status: String
    let message: String
}

struct TechnicalityResult: Codable {
    let brightness: Float
    let contrast: Float
    let saturation: Float
    let exposure: Float
}

struct TechnicalityStatus: Codable {
    let status: String
    let type: String
    let result: TechnicalityResult
}

// MARK: - API Service
class APIService {
    static let shared = APIService()
    private init() {}
    
    private let baseURL = "https://piccoach-be-1075160092468.asia-southeast1.run.app"
    
    // MARK: - JSON POST (like /suggestion)
    func postJSON<T: Codable, U: Codable>(
        endpoint: APIEndpoint,
        body: T,
        responseType: U.Type
    ) async throws -> U {
        guard let url = URL(string: baseURL + endpoint.path) else { throw URLError(.badURL) }
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
    
    // MARK: - Upload file and get image
    func uploadFileAsImage(
        endpoint: APIEndpoint,
        image: UIImage,
        fieldName: String = "file",
        imageUrl: String = ""
    ) async throws -> UIImage {
        guard let url = URL(string: baseURL + endpoint.path) else { throw URLError(.badURL) }
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
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image_url\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(imageUrl)\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        guard 200..<300 ~= httpResponse.statusCode else {
            print("Server returned HTTP \(httpResponse.statusCode): \(String(data: data, encoding: .utf8) ?? "")")
            throw URLError(.badServerResponse)
        }
        guard let outputImage = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        return outputImage
    }
    
    // MARK: - POST task (discard image result)
    func postImageTask(
        endpoint: APIEndpoint,
        image: UIImage
    ) async throws -> TaskResponse {
        guard let url = URL(string: baseURL + endpoint.path) else { throw URLError(.badURL) }
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
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
        return try JSONDecoder().decode(TaskResponse.self, from: data)
    }
    
    // MARK: - GET technicality status (JSON)
    func getTechnicalityStatus(taskID: String) async throws -> TechnicalityStatus {
        let endpoint = APIEndpoint.technicalityStatus(taskID: taskID)
        guard let url = URL(string: baseURL + endpoint.path) else { throw URLError(.badURL) }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(TechnicalityStatus.self, from: data)
    }
    
    // MARK: - GET enhance status (returns image)
    func getEnhanceStatus(taskID: String) async throws -> UIImage {
        let endpoint = APIEndpoint.enhanceStatus(taskID: taskID)
        guard let url = URL(string: baseURL + endpoint.path) else { throw URLError(.badURL) }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        // Decode JSON
        struct EnhanceStatusResponse: Decodable {
            struct Result: Decodable {
                let image_base64: String
            }
            let status: String
            let type: String
            let result: Result
        }

        let decoded = try JSONDecoder().decode(EnhanceStatusResponse.self, from: data)

        guard decoded.status == "completed" else {
            throw NSError(domain: "EnhanceTask", code: 0, userInfo: [NSLocalizedDescriptionKey: "Enhance task not completed"])
        }

        // Decode base64 image
        guard let imageData = Data(base64Encoded: decoded.result.image_base64, options: .ignoreUnknownCharacters),
              let image = UIImage(data: imageData) else {
            throw URLError(.cannotDecodeContentData)
        }

        return image
    }
}
