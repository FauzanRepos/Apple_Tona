//
//  ResultsViewModel.swift
//  Tona
//
//  Created by Apple Dev on 06/09/25.
//

import SwiftUI
import Combine

@MainActor
class ResultsViewModel: ObservableObject {
    @Published var resultImages: [UIImage] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var showingShareSheet = false
    
    private let apiService = APIService.shared
    private var jobId: String?
    private var cancellables = Set<AnyCancellable>()
    
    func loadResults(jobId: String) {
        self.jobId = jobId
        Task {
            await fetchResults()
        }
    }
    
    private func fetchResults() async {
        guard let jobId = jobId else { return }
        
        do {
            let resultResponse = try await apiService.getResult(jobId: jobId)
            
            // Load images from URLs
            var images: [UIImage] = []
            for urlString in resultResponse.resultUrls {
                if let url = URL(string: urlString),
                   let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    images.append(image)
                }
            }
            
            resultImages = images
            isLoading = false
            
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func saveToPhotos() {
        // TODO: Implement save to photos functionality
        print("Save to photos tapped")
    }
    
    func shareResults() {
        showingShareSheet = true
    }
    
    func processNewImages() {
        NotificationCenter.default.post(name: .navigateToUpload, object: nil)
    }
    
    func clearError() {
        errorMessage = nil
    }
}
