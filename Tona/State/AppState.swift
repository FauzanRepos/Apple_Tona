import SwiftUI
import Combine

// MARK: - Processing State
enum ProcessingState {
    case idle
    case uploading(progress: Double)
    case processing(progress: Double)
    case completed
    case failed(error: AppError)
}

// MARK: - App State
class AppState: ObservableObject {
    // Image Selection
    @Published var selectedImages: [UIImage] = []
    @Published var firstGroupImages: [UIImage] = []
    @Published var secondGroupImages: [UIImage] = []
    
    // Upload State
    @Published var firstGroupId: String?
    @Published var secondGroupId: String?
    @Published var uploadedGroupIds: [String] = []
    
    // Processing State
    @Published var currentJobId: String?
    @Published var processingState: ProcessingState = .idle
    @Published var processingProgress: Double = 0.0
    
    // Results
    @Published var processedResults: [UIImage] = []
    @Published var currentResult: UIImage?
    
    // Error Management
    @Published var currentError: AppError?
    @Published var errorHistory: [AppError] = []
    @Published var currentToast: ToastConfiguration?
    
    // UI State
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    
    // Loading States
    let loadingManager = LoadingStateManager()
    let toastManager = ToastManager()
    
    // MARK: - Computed Properties
    var hasFirstGroup: Bool {
        firstGroupId != nil
    }
    
    var hasSecondGroup: Bool {
        secondGroupId != nil
    }
    
    var canStartProcessing: Bool {
        if case .idle = processingState {
            return hasFirstGroup && hasSecondGroup
        }
        return false
    }
    
    var isProcessing: Bool {
        switch processingState {
        case .uploading, .processing:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Methods
    func reset() {
        selectedImages = []
        firstGroupImages = []
        secondGroupImages = []
        firstGroupId = nil
        secondGroupId = nil
        uploadedGroupIds = []
        currentJobId = nil
        processingState = .idle
        processingProgress = 0.0
        processedResults = []
        currentResult = nil
        currentError = nil
        isLoading = false
        showError = false
    }
    
    func addError(_ error: AppError) {
        currentError = error
        errorHistory.append(error)
        
        if error.isFatal {
            showError = true
        } else {
            // Show toast for non-fatal errors
            toastManager.showError(
                error.errorDescription ?? "An error occurred",
                action: error.canRetry ? { self.retryLastAction() } : nil,
                actionTitle: error.canRetry ? "Retry" : nil
            )
        }
    }
    
    func addError(_ errorMessage: String) {
        let error = AppError.unknown(errorMessage)
        addError(error)
    }
    
    func clearCurrentError() {
        currentError = nil
        showError = false
    }
    
    // MARK: - Retry Support
    private var lastRetryableAction: (() async -> Void)?
    
    func setRetryableAction(_ action: @escaping () async -> Void) {
        lastRetryableAction = action
    }
    
    func retryLastAction() {
        guard let action = lastRetryableAction else { return }
        Task {
            await action()
        }
    }
    
    func updateProgress(_ progress: Double) {
        processingProgress = progress
        switch processingState {
        case .uploading:
            processingState = .uploading(progress: progress)
            loadingManager.updateProgress(for: "upload", progress: progress, message: "Uploading images...")
        case .processing:
            processingState = .processing(progress: progress)
            loadingManager.updateProgress(for: "processing", progress: progress, message: "Processing images...")
        default:
            break
        }
    }
    
    // MARK: - Loading State Helpers
    func startLoading(key: String, message: String? = nil) {
        loadingManager.startLoading(for: key, message: message)
        isLoading = loadingManager.isAnyLoading
    }
    
    func stopLoading(key: String) {
        loadingManager.stopLoading(for: key)
        isLoading = loadingManager.isAnyLoading
    }
    
    // MARK: - Toast Helpers
    func showSuccess(_ message: String) {
        toastManager.showSuccess(message)
    }
    
    func showInfo(_ message: String) {
        toastManager.showInfo(message)
    }
}
