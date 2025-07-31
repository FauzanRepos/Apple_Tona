import Foundation
import UIKit

// MARK: - Error Types
enum TonaAPIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse(statusCode: Int)
    case requestFailed(description: String)
    case decodingFailed
    case encodingFailed
    case noData
    case networkError(Error)
    case serverError(message: String)
    case fileTooLarge
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse(let statusCode):
            return "Invalid response with status code: \(statusCode)"
        case .requestFailed(let description):
            return "Request failed: \(description)"
        case .decodingFailed:
            return "Failed to decode response"
        case .encodingFailed:
            return "Failed to encode request"
        case .noData:
            return "No data received"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .fileTooLarge:
            return "File size exceeds 10MB limit"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}

// MARK: - Request/Response Models
struct UploadGroupResponse: Codable {
    let success: Bool
    let message: String?
    let groupId: String?
}

struct ProcessingRequest: Codable {
    let firstGroupId: String
    let secondGroupId: String
    let options: ProcessingOptions?
}

struct ProcessingOptions: Codable {
    let quality: String?
    let format: String?
}

struct ProcessingResponse: Codable {
    let success: Bool
    let jobId: String?
    let message: String?
}

struct StatusResponse: Codable {
    let status: JobStatus
    let progress: Double?
    let message: String?
}

enum JobStatus: String, Codable {
    case pending = "pending"
    case processing = "processing"
    case completed = "completed"
    case failed = "failed"
    case cancelled = "cancelled"
}

struct ResultResponse: Codable {
    let success: Bool
    let resultUrl: String?
    let data: Data?
    let message: String?
}

struct CancelResponse: Codable {
    let success: Bool
    let message: String?
}

// MARK: - Image Upload Data
struct ImageUpload {
    let images: [UIImage]
    let groupName: String
}

// MARK: - TonaAPI Class
class TonaAPI {
    private let session: URLSession
    private let baseURL: String
    private let maxFileSize: Int = 10 * 1024 * 1024 // 10 MB
    
    init(baseURL: String = "https://api.tona.app", session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    // MARK: - Public API Methods
    
    /// Upload first group of images
    func uploadFirstGroup(images: [UIImage]) async throws -> UploadGroupResponse {
        let imageData = try prepareImagesForUpload(images)
        
        // Check if we need background transfer
        if shouldUseBackgroundTransfer(for: imageData) {
            return try await uploadGroupWithBackgroundTransfer(endpoint: "/api/v1/upload/first-group", images: imageData)
        } else {
            return try await uploadGroup(endpoint: "/api/v1/upload/first-group", images: imageData)
        }
    }
    
    /// Upload second group of images
    func uploadSecondGroup(images: [UIImage]) async throws -> UploadGroupResponse {
        let imageData = try prepareImagesForUpload(images)
        
        // Check if we need background transfer
        if shouldUseBackgroundTransfer(for: imageData) {
            return try await uploadGroupWithBackgroundTransfer(endpoint: "/api/v1/upload/second-group", images: imageData)
        } else {
            return try await uploadGroup(endpoint: "/api/v1/upload/second-group", images: imageData)
        }
    }
    
    /// Start processing job
    func startProcessing(firstGroupId: String, secondGroupId: String, options: ProcessingOptions? = nil) async throws -> ProcessingResponse {
        let url = try buildURL(endpoint: "/api/v1/process/start")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ProcessingRequest(
            firstGroupId: firstGroupId,
            secondGroupId: secondGroupId,
            options: options
        )
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        try validateResponse(response)
        
        return try JSONDecoder().decode(ProcessingResponse.self, from: data)
    }
    
    /// Check job status
    func checkStatus(jobId: String) async throws -> StatusResponse {
        let url = try buildURL(endpoint: "/api/v1/status/\(jobId)")
        
        let (data, response) = try await session.data(from: url)
        
        try validateResponse(response)
        
        return try JSONDecoder().decode(StatusResponse.self, from: data)
    }
    
    /// Get processing result
    func getResult(jobId: String) async throws -> ResultResponse {
        let url = try buildURL(endpoint: "/api/v1/result/\(jobId)")
        
        let (data, response) = try await session.data(from: url)
        
        try validateResponse(response)
        
        return try JSONDecoder().decode(ResultResponse.self, from: data)
    }
    
    /// Cancel processing job
    func cancelJob(jobId: String) async throws -> CancelResponse {
        let url = try buildURL(endpoint: "/api/v1/cancel/\(jobId)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (data, response) = try await session.data(for: request)
        
        try validateResponse(response)
        
        return try JSONDecoder().decode(CancelResponse.self, from: data)
    }
    
    // MARK: - Private Helper Methods
    
    private func buildURL(endpoint: String) throws -> URL {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw TonaAPIError.invalidURL
        }
        return url
    }
    
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TonaAPIError.invalidResponse(statusCode: 0)
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            break
        case 400:
            throw TonaAPIError.requestFailed(description: "Bad request")
        case 401:
            throw TonaAPIError.requestFailed(description: "Unauthorized")
        case 404:
            throw TonaAPIError.requestFailed(description: "Not found")
        case 500...599:
            throw TonaAPIError.serverError(message: "Server error")
        default:
            throw TonaAPIError.invalidResponse(statusCode: httpResponse.statusCode)
        }
    }
    
    private func prepareImagesForUpload(_ images: [UIImage]) throws -> [(name: String, data: Data)] {
        var imageData: [(name: String, data: Data)] = []
        
        for (index, image) in images.enumerated() {
            guard let data = image.jpegData(compressionQuality: 0.8) else {
                throw TonaAPIError.encodingFailed
            }
            imageData.append((name: "image_\(index).jpg", data: data))
        }
        
        return imageData
    }
    
    private func shouldUseBackgroundTransfer(for images: [(name: String, data: Data)]) -> Bool {
        let totalSize = images.reduce(0) { $0 + $1.data.count }
        return totalSize > maxFileSize
    }
    
    private func uploadGroup(endpoint: String, images: [(name: String, data: Data)]) async throws -> UploadGroupResponse {
        let url = try buildURL(endpoint: endpoint)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = createMultipartBody(images: images, boundary: boundary)
        
        let (data, response) = try await session.data(for: request)
        
        try validateResponse(response)
        
        return try JSONDecoder().decode(UploadGroupResponse.self, from: data)
    }
    
    private func uploadGroupWithBackgroundTransfer(endpoint: String, images: [(name: String, data: Data)]) async throws -> UploadGroupResponse {
        // Create background session configuration
        let config = URLSessionConfiguration.background(withIdentifier: "com.tona.upload.\(UUID().uuidString)")
        let backgroundSession = URLSession(configuration: config)
        
        let url = try buildURL(endpoint: endpoint)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create temporary file for upload
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let uploadData = createMultipartBody(images: images, boundary: boundary)
        try uploadData.write(to: tempURL)
        
        // Create upload task
        let task = backgroundSession.uploadTask(with: request, fromFile: tempURL)
        
        // Use continuation to bridge to async/await
        return try await withCheckedThrowingContinuation { continuation in
            task.resume()
            
            // For now, we'll use a simple polling mechanism
            // In a real app, you'd implement URLSessionDelegate methods
            Task {
                // Simulate completion - in reality, you'd track this via delegate
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                
                // Clean up temp file
                try? FileManager.default.removeItem(at: tempURL)
                
                // Return mock response for now
                let response = UploadGroupResponse(success: true, message: "Background upload initiated", groupId: UUID().uuidString)
                continuation.resume(returning: response)
            }
        }
    }
    
    private func createMultipartBody(images: [(name: String, data: Data)], boundary: String) -> Data {
        var body = Data()
        
        for image in images {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"images\"; filename=\"\(image.name)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(image.data)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
}
