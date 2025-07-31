import SwiftUI
import Combine

// MARK: - Result View Model
class ResultVM: ObservableObject {
    // Published Properties
    @Published var results: [UIImage] = []
    @Published var resultUrls: [String] = []
    @Published var isLoadingResults: Bool = false
    @Published var resultError: String?
    @Published var selectedResult: UIImage?
    @Published var downloadProgress: Double = 0.0
    
    // Dependencies
    private let tonaAPI: TonaAPI
    private let appState: AppState
    private var cancellables = Set<AnyCancellable>()
    
    init(tonaAPI: TonaAPI, appState: AppState) {
        self.tonaAPI = tonaAPI
        self.appState = appState
        
        // Subscribe to processing state changes
        appState.$processingState
            .sink { [weak self] state in
                if case .completed = state {
                    Task {
                        await self?.fetchResults()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func fetchResults() async {
        guard let jobId = appState.currentJobId else {
            resultError = "No job ID available"
            return
        }
        
        isLoadingResults = true
        resultError = nil
        downloadProgress = 0.0
        
        do {
            let response = try await tonaAPI.getResult(jobId: jobId)
            
            if response.success {
                // Handle result based on response type
                if let imageData = response.data,
                   let image = UIImage(data: imageData) {
                    // Direct image data
                    results = [image]
                    appState.processedResults = [image]
                    appState.currentResult = image
                } else if let resultUrl = response.resultUrl {
                    // Download from URL
                    resultUrls = [resultUrl]
                    await downloadResults(from: [resultUrl])
                } else {
                    throw TonaAPIError.noData
                }
            } else {
                throw TonaAPIError.requestFailed(description: response.message ?? "Failed to fetch results")
            }
            
        } catch {
            resultError = error.localizedDescription
            appState.addError(error.localizedDescription)
        }
        
        isLoadingResults = false
    }
    
    func downloadResults(from urls: [String]) async {
        var downloadedImages: [UIImage] = []
        
        for (index, urlString) in urls.enumerated() {
            guard let url = URL(string: urlString) else {
                continue
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                if let image = UIImage(data: data) {
                    downloadedImages.append(image)
                    
                    // Update progress
                    downloadProgress = Double(index + 1) / Double(urls.count)
                }
                
            } catch {
                print("Failed to download image from \(urlString): \(error)")
            }
        }
        
        results = downloadedImages
        appState.processedResults = downloadedImages
        
        if let firstImage = downloadedImages.first {
            selectedResult = firstImage
            appState.currentResult = firstImage
        }
    }
    
    func selectResult(_ image: UIImage) {
        selectedResult = image
        appState.currentResult = image
    }
    
    func saveResult(_ image: UIImage) {
        // Save to photo library
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func shareResult(_ image: UIImage) -> UIActivityViewController {
        let activityController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        return activityController
    }
    
    func clearResults() {
        results = []
        resultUrls = []
        selectedResult = nil
        resultError = nil
        downloadProgress = 0.0
        appState.processedResults = []
        appState.currentResult = nil
    }
    
    // MARK: - Computed Properties
    var hasResults: Bool {
        !results.isEmpty
    }
    
    var resultCount: Int {
        results.count
    }
}
