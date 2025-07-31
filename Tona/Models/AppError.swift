import Foundation

// MARK: - App Error Types
enum AppError: Error, LocalizedError, Identifiable {
    case network(NetworkError)
    case validation(ValidationError)
    case processing(ProcessingError)
    case storage(StorageError)
    case unknown(String)
    
    var id: String {
        switch self {
        case .network(let error): return "network_\(error.id)"
        case .validation(let error): return "validation_\(error.id)"
        case .processing(let error): return "processing_\(error.id)"
        case .storage(let error): return "storage_\(error.id)"
        case .unknown(let message): return "unknown_\(message)"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .network(let error): return error.localizedDescription
        case .validation(let error): return error.localizedDescription
        case .processing(let error): return error.localizedDescription
        case .storage(let error): return error.localizedDescription
        case .unknown(let message): return message
        }
    }
    
    var isFatal: Bool {
        switch self {
        case .network(let error): return error.isFatal
        case .processing(let error): return error.isFatal
        case .validation, .storage, .unknown: return false
        }
    }
    
    var canRetry: Bool {
        switch self {
        case .network(let error): return error.canRetry
        case .processing(let error): return error.canRetry
        case .validation, .storage, .unknown: return false
        }
    }
}

// MARK: - Network Errors
enum NetworkError: Error, LocalizedError, Identifiable {
    case noConnection
    case timeout
    case serverError(statusCode: Int)
    case invalidResponse
    case requestFailed(String)
    
    var id: String {
        switch self {
        case .noConnection: return "no_connection"
        case .timeout: return "timeout"
        case .serverError(let code): return "server_\(code)"
        case .invalidResponse: return "invalid_response"
        case .requestFailed(let msg): return "request_failed_\(msg)"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No internet connection. Please check your network settings."
        case .timeout:
            return "Request timed out. Please try again."
        case .serverError(let statusCode):
            return "Server error (Code: \(statusCode)). Please try again later."
        case .invalidResponse:
            return "Invalid response from server."
        case .requestFailed(let description):
            return "Request failed: \(description)"
        }
    }
    
    var isFatal: Bool {
        switch self {
        case .noConnection: return true
        case .serverError(let code): return code >= 500
        default: return false
        }
    }
    
    var canRetry: Bool {
        switch self {
        case .noConnection, .timeout, .serverError: return true
        default: return false
        }
    }
}

// MARK: - Validation Errors
enum ValidationError: Error, LocalizedError, Identifiable {
    case noImagesSelected
    case tooManyImages(max: Int)
    case invalidImageFormat
    case fileTooLarge(maxSizeMB: Int)
    
    var id: String {
        switch self {
        case .noImagesSelected: return "no_images"
        case .tooManyImages(let max): return "too_many_\(max)"
        case .invalidImageFormat: return "invalid_format"
        case .fileTooLarge(let max): return "file_too_large_\(max)"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .noImagesSelected:
            return "Please select at least one image to continue."
        case .tooManyImages(let max):
            return "You can select up to \(max) images."
        case .invalidImageFormat:
            return "Invalid image format. Please use JPEG or PNG images."
        case .fileTooLarge(let maxSizeMB):
            return "File size exceeds \(maxSizeMB)MB limit."
        }
    }
}

// MARK: - Processing Errors
enum ProcessingError: Error, LocalizedError, Identifiable {
    case jobFailed(reason: String)
    case jobCancelled
    case processingTimeout
    case invalidJobId
    
    var id: String {
        switch self {
        case .jobFailed(let reason): return "job_failed_\(reason)"
        case .jobCancelled: return "job_cancelled"
        case .processingTimeout: return "processing_timeout"
        case .invalidJobId: return "invalid_job_id"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .jobFailed(let reason):
            return "Processing failed: \(reason)"
        case .jobCancelled:
            return "Processing was cancelled."
        case .processingTimeout:
            return "Processing took too long. Please try again."
        case .invalidJobId:
            return "Invalid processing job."
        }
    }
    
    var isFatal: Bool {
        switch self {
        case .jobFailed, .processingTimeout: return true
        default: return false
        }
    }
    
    var canRetry: Bool {
        switch self {
        case .jobFailed, .processingTimeout: return true
        default: return false
        }
    }
}

// MARK: - Storage Errors
enum StorageError: Error, LocalizedError, Identifiable {
    case saveFailed
    case loadFailed
    case insufficientSpace
    
    var id: String {
        switch self {
        case .saveFailed: return "save_failed"
        case .loadFailed: return "load_failed"
        case .insufficientSpace: return "insufficient_space"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Failed to save image. Please try again."
        case .loadFailed:
            return "Failed to load image."
        case .insufficientSpace:
            return "Not enough storage space available."
        }
    }
}

// MARK: - Error Extensions
extension AppError {
    /// Convert from TonaAPIError to AppError
    static func from(_ tonaError: TonaAPIError) -> AppError {
        switch tonaError {
        case .invalidURL:
            return .network(.invalidResponse)
        case .invalidResponse(let code):
            return .network(.serverError(statusCode: code))
        case .requestFailed(let description):
            return .network(.requestFailed(description))
        case .networkError:
            return .network(.noConnection)
        case .serverError(let message):
            return .network(.requestFailed(message))
        case .fileTooLarge:
            return .validation(.fileTooLarge(maxSizeMB: 10))
        case .decodingFailed, .encodingFailed, .noData, .unknown:
            return .unknown(tonaError.localizedDescription)
        }
    }
}
