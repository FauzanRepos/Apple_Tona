//
//  ResultsView.swift
//  Tona
//
//  Created by Apple Dev on 06/09/25.
//

import SwiftUI

struct ResultsView: View {
    @StateObject private var viewModel = ResultsViewModel()
    @State private var jobId: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("Processing Complete")
                        .font(.tonaTitle1())
                        .foregroundColor(TonaColors.primaryDarkBlue)
                    
                    Text("Your enhanced images are ready")
                        .font(.tonaBody())
                        .foregroundColor(TonaColors.darkGray)
                }
                .padding(.top, 20)
                .padding(.bottom, 32)
                
                // Results Grid
                if viewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading results...")
                            .font(.tonaBody())
                            .foregroundColor(TonaColors.darkGray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.resultImages.isEmpty {
                    // Placeholder for results
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64, weight: .regular))
                            .foregroundColor(TonaColors.success)
                        
                        Text("Results will appear here")
                            .font(.tonaBody())
                            .foregroundColor(TonaColors.darkGray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                            ForEach(0..<viewModel.resultImages.count, id: \.self) { index in
                                PhotoCard(image: Image(uiImage: viewModel.resultImages[index])) {
                                    // TODO: Implement full screen preview
                                    print("Result image \(index) tapped")
                                }
                            }
                        }
                        .padding(.horizontal, TonaSpacing.screenMargins)
                    }
                }
                
                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.tonaCaption())
                        .foregroundColor(TonaColors.error)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    TonaButton("Save to Photos", style: .primary, isEnabled: !viewModel.resultImages.isEmpty) {
                        viewModel.saveToPhotos()
                    }
                    
                    TonaButton("Share Results", style: .secondary, isEnabled: !viewModel.resultImages.isEmpty) {
                        viewModel.shareResults()
                    }
                    
                    TonaButton("Process New Images", style: .secondary) {
                        viewModel.processNewImages()
                    }
                }
                .padding(.horizontal, TonaSpacing.screenMargins)
                .padding(.bottom, 40)
            }
            .background(TonaColors.lightGray)
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showingShareSheet) {
                // TODO: Implement share sheet
                Text("Share Sheet")
            }
            .onReceive(NotificationCenter.default.publisher(for: .navigateToResults)) { notification in
                if let jobId = notification.object as? String {
                    self.jobId = jobId
                    viewModel.loadResults(jobId: jobId)
                }
            }
        }
    }
}

#Preview {
    ResultsView()
}
