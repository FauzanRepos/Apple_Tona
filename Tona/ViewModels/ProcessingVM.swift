import SwiftUI
import Combine

// MARK: - Processing View Model
class ProcessingVM: ObservableObject {
    // Published Properties
    @Published var currentJobId: String?
    @Published var jobStatus: JobStatus = .pending
    @Published var progress: Double = 0.0
    @Published var isProcessing: Bool = false
    @Published var statusMessage: String?
    
    // Dependencies
    private let tonaAPI: TonaAPI
    private let appState: AppState
    private var statusCheckTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init(tonaAPI: TonaAPI, appState: AppState) {
        self.tonaAPI = tonaAPI
        self.appState = appState
    }
    
    // MARK: - Public Methods
    func startProcessing(options: ProcessingOptions? = nil) async {
        guard appState.canStartProcessing,
              let firstGroupId = appState.firstGroupId,
              let secondGroupId = appState.secondGroupId else {
            appState.addError(AppError.validation(.noImagesSelected))
            return
        }
        
        isProcessing = true
        progress = 0.0
        appState.processingState = .processing(progress: 0.0)
        appState.startLoading(key: "processing", message: "Starting processing...")
        
        do {
            // Start processing
            let response = try await tonaAPI.startProcessing(
                firstGroupId: firstGroupId,
                secondGroupId: secondGroupId,
                options: options
            )
            
            if response.success, let jobId = response.jobId {
                currentJobId = jobId
                appState.currentJobId = jobId
                
                // Start monitoring job status
                startStatusMonitoring(jobId: jobId)
            } else {
                throw TonaAPIError.requestFailed(description: response.message ?? "Failed to start processing")
            }
            
        } catch {
            let appError: AppError
            if let tonaError = error as? TonaAPIError {
                appError = AppError.from(tonaError)
            } else {
                appError = AppError.processing(.jobFailed(reason: error.localizedDescription))
            }
            
            appState.addError(appError)
            appState.stopLoading(key: "processing")
            appState.processingState = .failed(error: appError)
            isProcessing = false
        }
    }
    
    func cancelProcessing() async {
        guard let jobId = currentJobId else { return }
        
        stopStatusMonitoring()
        
        do {
            let response = try await tonaAPI.cancelJob(jobId: jobId)
            
            if response.success {
                jobStatus = .cancelled
                appState.processingState = .idle
                statusMessage = response.message ?? "Processing cancelled"
            } else {
                throw TonaAPIError.requestFailed(description: response.message ?? "Failed to cancel job")
            }
            
        } catch {
            appState.addError(error.localizedDescription)
        }
        
        isProcessing = false
        currentJobId = nil
        appState.currentJobId = nil
    }
    
    func checkStatus() async {
        guard let jobId = currentJobId else { return }
        
        do {
            let statusResponse = try await tonaAPI.checkStatus(jobId: jobId)
            
            jobStatus = statusResponse.status
            statusMessage = statusResponse.message
            
            if let progressValue = statusResponse.progress {
                progress = progressValue
                appState.updateProgress(progressValue)
            }
            
            switch statusResponse.status {
            case .completed:
                appState.processingState = .completed
                appState.stopLoading(key: "processing")
                appState.showSuccess("Processing completed successfully")
                stopStatusMonitoring()
                isProcessing = false
                
            case .failed:
                let errorMessage = statusResponse.message ?? "Processing failed"
                let appError = AppError.processing(.jobFailed(reason: errorMessage))
                appState.processingState = .failed(error: appError)
                appState.addError(appError)
                stopStatusMonitoring()
                isProcessing = false
                
            case .cancelled:
                appState.processingState = .idle
                stopStatusMonitoring()
                isProcessing = false
                
            case .processing, .pending:
                // Continue monitoring
                break
            }
            
        } catch {
            appState.addError(error.localizedDescription)
        }
    }
    
    // MARK: - Private Methods
    private func startStatusMonitoring(jobId: String) {
        stopStatusMonitoring()
        
        // Check status immediately
        Task {
            await checkStatus()
        }
        
        // Then check every 2 seconds
        statusCheckTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task {
                await self?.checkStatus()
            }
        }
    }
    
    private func stopStatusMonitoring() {
        statusCheckTimer?.invalidate()
        statusCheckTimer = nil
    }
    
    deinit {
        stopStatusMonitoring()
    }
}
