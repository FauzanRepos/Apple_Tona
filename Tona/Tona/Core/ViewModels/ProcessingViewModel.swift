//
//  ProcessingViewModel.swift
//  Tona
//
//  Created by Apple Dev on 06/09/25.
//

import SwiftUI
import Combine

@MainActor
class ProcessingViewModel: ObservableObject {
    @Published var progress: Double = 0.0
    @Published var currentStep: String = "Initializing..."
    @Published var isProcessing = true
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    private var jobId: String?
    private var statusTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    func startProcessing(jobId: String) {
        self.jobId = jobId
        startStatusPolling()
    }
    
    private func startStatusPolling() {
        statusTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.checkStatus()
            }
        }
    }
    
    private func checkStatus() async {
        guard let jobId = jobId else { return }
        
        do {
            let statusResponse = try await apiService.checkStatus(jobId: jobId)
            
            progress = Double(statusResponse.progress) / 100.0
            currentStep = statusResponse.currentStep
            
            if statusResponse.finished {
                isProcessing = false
                statusTimer?.invalidate()
                statusTimer = nil
                
                if statusResponse.errors.isEmpty {
                    // Navigate to results
                    NotificationCenter.default.post(name: .navigateToResults, object: jobId)
                } else {
                    errorMessage = statusResponse.errors.joined(separator: ", ")
                }
            }
            
        } catch {
            errorMessage = error.localizedDescription
            isProcessing = false
            statusTimer?.invalidate()
            statusTimer = nil
        }
    }
    
    func cancelProcessing() {
        guard let jobId = jobId else { return }
        
        Task {
            do {
                _ = try await apiService.cancelJob(jobId: jobId)
                isProcessing = false
                statusTimer?.invalidate()
                statusTimer = nil
                
                // Navigate back to upload
                NotificationCenter.default.post(name: .navigateToUpload, object: nil)
                
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    deinit {
        statusTimer?.invalidate()
    }
}
