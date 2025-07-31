import SwiftUI
import Combine

// MARK: - Upload Type
enum UploadGroupType {
    case first
    case second
}

// MARK: - Upload View Model
class UploadVM: ObservableObject {
    // Published Properties
    @Published var imagesToUpload: [UIImage] = []
    @Published var uploadGroupType: UploadGroupType = .first
    @Published var isUploading: Bool = false
    @Published var uploadProgress: Double = 0.0
    @Published var uploadError: String?
    @Published var groupId: String?
    
    // Dependencies
    private let tonaAPI: TonaAPI
    private let appState: AppState
    private var cancellables = Set<AnyCancellable>()
    
    init(tonaAPI: TonaAPI, appState: AppState) {
        self.tonaAPI = tonaAPI
        self.appState = appState
    }
    
    // MARK: - Public Methods
    func uploadImages() async {
        guard !imagesToUpload.isEmpty else {
            appState.addError(AppError.validation(.noImagesSelected))
            return
        }
        
        // Set retryable action
        appState.setRetryableAction { [weak self] in
            await self?.uploadImages()
        }
        
        isUploading = true
        uploadError = nil
        appState.processingState = .uploading(progress: 0.0)
        appState.startLoading(key: "upload", message: "Preparing upload...")
        
        do {
            let response: UploadGroupResponse
            
            switch uploadGroupType {
            case .first:
                response = try await tonaAPI.uploadFirstGroup(images: imagesToUpload)
                if let groupId = response.groupId {
                    appState.firstGroupId = groupId
                    appState.firstGroupImages = imagesToUpload
                }
            case .second:
                response = try await tonaAPI.uploadSecondGroup(images: imagesToUpload)
                if let groupId = response.groupId {
                    appState.secondGroupId = groupId
                    appState.secondGroupImages = imagesToUpload
                }
            }
            
            if response.success, let groupId = response.groupId {
                self.groupId = groupId
                appState.uploadedGroupIds.append(groupId)
                appState.processingState = .idle
                appState.showSuccess("Images uploaded successfully")
            } else {
                throw TonaAPIError.requestFailed(description: response.message ?? "Upload failed")
            }
            
        } catch {
            let appError: AppError
            if let tonaError = error as? TonaAPIError {
                appError = AppError.from(tonaError)
            } else {
                appError = AppError.network(.requestFailed(error.localizedDescription))
            }
            
            uploadError = appError.errorDescription
            appState.addError(appError)
            appState.processingState = .failed(error: appError)
        }
        
        appState.stopLoading(key: "upload")
        isUploading = false
        uploadProgress = 0.0
    }
    
    func addImage(_ image: UIImage) {
        imagesToUpload.append(image)
    }
    
    func removeImage(at index: Int) {
        guard imagesToUpload.indices.contains(index) else { return }
        imagesToUpload.remove(at: index)
    }
    
    func clearImages() {
        imagesToUpload = []
        uploadError = nil
        groupId = nil
    }
    
    func setUploadType(_ type: UploadGroupType) {
        uploadGroupType = type
    }
    
    // MARK: - Private Methods
    private func simulateProgress() {
        Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .prefix(while: { [weak self] _ in
                self?.isUploading ?? false
            })
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.uploadProgress < 0.9 {
                    self.uploadProgress += 0.1
                    self.appState.updateProgress(self.uploadProgress)
                }
            }
            .store(in: &cancellables)
    }
}
