//
//  PhotoUploadViewModel.swift
//  Tona
//
//  Created by Apple Dev on 06/09/25.
//

import SwiftUI
import Combine
import PhotosUI

@MainActor
class PhotoUploadViewModel: ObservableObject {
    @Published var firstGroupImages: [UIImage] = []
    @Published var secondGroupImages: [UIImage] = []
    @Published var isFirstGroupPickerPresented = false
    @Published var isSecondGroupPickerPresented = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Photo Selection
    func selectFirstGroupPhotos() {
        isFirstGroupPickerPresented = true
    }
    
    func selectSecondGroupPhotos() {
        isSecondGroupPickerPresented = true
    }
    
    func handleFirstGroupSelection(_ result: Result<[PhotosPickerItem], Error>) {
        switch result {
        case .success(let items):
            Task {
                await loadImages(from: items, to: \PhotoUploadViewModel.firstGroupImages)
            }
        case .failure(let error):
            errorMessage = "Failed to select photos: \(error.localizedDescription)"
        }
    }
    
    func handleSecondGroupSelection(_ result: Result<[PhotosPickerItem], Error>) {
        switch result {
        case .success(let items):
            Task {
                await loadImages(from: items, to: \PhotoUploadViewModel.secondGroupImages)
            }
        case .failure(let error):
            errorMessage = "Failed to select photos: \(error.localizedDescription)"
        }
    }
    
    func loadImages(from items: [PhotosPickerItem], to keyPath: ReferenceWritableKeyPath<PhotoUploadViewModel, [UIImage]>) async {
        var images: [UIImage] = []
        
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                images.append(image)
            }
        }
        
        self[keyPath: keyPath] = images
    }
    
    // MARK: - Image Management
    func removeFirstGroupImage(at index: Int) {
        guard index < firstGroupImages.count else { return }
        firstGroupImages.remove(at: index)
    }
    
    func removeSecondGroupImage(at index: Int) {
        guard index < secondGroupImages.count else { return }
        secondGroupImages.remove(at: index)
    }
    
    func addMoreFirstGroupPhotos() {
        isFirstGroupPickerPresented = true
    }
    
    func addMoreSecondGroupPhotos() {
        isSecondGroupPickerPresented = true
    }
    
    // MARK: - Processing
    var canStartProcessing: Bool {
        !firstGroupImages.isEmpty && !secondGroupImages.isEmpty && !isLoading
    }
    
    func startProcessing() {
        guard canStartProcessing else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Convert images to data
                let firstGroupData = firstGroupImages.compactMap { $0.jpegData(compressionQuality: 0.8) }
                let secondGroupData = secondGroupImages.compactMap { $0.jpegData(compressionQuality: 0.8) }
                
                // Upload first group
                let firstGroupResponse = try await apiService.uploadFirstGroup(files: firstGroupData)
                
                // Upload second group
                let secondGroupResponse = try await apiService.uploadSecondGroup(files: secondGroupData)
                
                // Start processing
                let processingRequest = ProcessingRequest(
                    userId: "user_123456",
                    jobName: "AI Wrapping Job",
                    firstGroupId: firstGroupResponse.groupId,
                    secondGroupId: secondGroupResponse.groupId,
                    notifyUrl: "https://yourapp.com/hooks/job-status",
                    options: ProcessingOptions(
                        style: "realistic",
                        faceEnhancement: true,
                        targetResolution: "1024x1024"
                    )
                )
                
                let processingResponse = try await apiService.startProcessing(request: processingRequest)
                
                // Navigate to processing screen
                NotificationCenter.default.post(name: .navigateToProcessing, object: processingResponse.jobId)
                
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}
