//
//  APIService.swift
//  Tona
//
//  Created by Apple Dev on 06/09/25.
//

import Foundation
import Combine

class APIService: ObservableObject {
    static let shared = APIService()
    
    private let baseURL = "https://your-project.supabase.co"
    private let session = URLSession.shared
    
    private init() {}
    
    // MARK: - Upload First Group
    func uploadFirstGroup(files: [Data]) async throws -> UploadResponse {
        let url = URL(string: "\(baseURL)/upload-first-group")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let httpBody = createMultipartBody(files: files, boundary: boundary)
        request.httpBody = httpBody
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.uploadFailed
        }
        
        return try JSONDecoder().decode(UploadResponse.self, from: data)
    }
    
    // MARK: - Upload Second Group
    func uploadSecondGroup(files: [Data]) async throws -> UploadResponse {
        let url = URL(string: "\(baseURL)/upload-second-group")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let httpBody = createMultipartBody(files: files, boundary: boundary)
        request.httpBody = httpBody
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.uploadFailed
        }
        
        return try JSONDecoder().decode(UploadResponse.self, from: data)
    }
    
    // MARK: - Start Processing
    func startProcessing(request: ProcessingRequest) async throws -> ProcessingResponse {
        let url = URL(string: "\(baseURL)/start-processing")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try JSONEncoder().encode(request)
        urlRequest.httpBody = jsonData
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.processingFailed
        }
        
        return try JSONDecoder().decode(ProcessingResponse.self, from: data)
    }
    
    // MARK: - Check Status
    func checkStatus(jobId: String) async throws -> StatusResponse {
        let url = URL(string: "\(baseURL)/status/\(jobId)")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.statusCheckFailed
        }
        
        return try JSONDecoder().decode(StatusResponse.self, from: data)
    }
    
    // MARK: - Get Result
    func getResult(jobId: String) async throws -> ResultResponse {
        let url = URL(string: "\(baseURL)/result/\(jobId)")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.resultFetchFailed
        }
        
        return try JSONDecoder().decode(ResultResponse.self, from: data)
    }
    
    // MARK: - Cancel Job
    func cancelJob(jobId: String) async throws -> CancelResponse {
        let url = URL(string: "\(baseURL)/cancel/\(jobId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.cancelFailed
        }
        
        return try JSONDecoder().decode(CancelResponse.self, from: data)
    }
    
    // MARK: - Helper Methods
    private func createMultipartBody(files: [Data], boundary: String) -> Data {
        var body = Data()
        
        for (index, fileData) in files.enumerated() {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"files[]\"; filename=\"image\(index).jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(fileData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}

// MARK: - API Models
struct UploadResponse: Codable {
    let message: String
    let groupId: String
}

struct ProcessingRequest: Codable {
    let userId: String
    let jobName: String
    let firstGroupId: String
    let secondGroupId: String
    let notifyUrl: String
    let options: ProcessingOptions
}

struct ProcessingOptions: Codable {
    let style: String
    let faceEnhancement: Bool
    let targetResolution: String
}

struct ProcessingResponse: Codable {
    let jobId: String
    let message: String
}

struct StatusResponse: Codable {
    let jobId: String
    let status: String
    let progress: Int
    let currentStep: String
    let finished: Bool
    let errors: [String]
}

struct ResultResponse: Codable {
    let jobId: String
    let finished: Bool
    let resultUrls: [String]
}

struct CancelResponse: Codable {
    let message: String
    let jobId: String
}

// MARK: - API Errors
enum APIError: Error, LocalizedError {
    case uploadFailed
    case processingFailed
    case statusCheckFailed
    case resultFetchFailed
    case cancelFailed
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .uploadFailed:
            return "Failed to upload files"
        case .processingFailed:
            return "Failed to start processing"
        case .statusCheckFailed:
            return "Failed to check status"
        case .resultFetchFailed:
            return "Failed to fetch results"
        case .cancelFailed:
            return "Failed to cancel job"
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
}
