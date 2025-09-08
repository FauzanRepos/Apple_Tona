//
//  PhotoUploadView.swift
//  Tona
//
//  Created by Apple Dev on 06/09/25.
//

import SwiftUI
import PhotosUI

struct PhotoUploadView: View {
    @StateObject private var viewModel = PhotoUploadViewModel()
    @State private var isFirstGroupDragOver = false
    @State private var isSecondGroupDragOver = false
    @State private var firstGroupSelection: [PhotosPickerItem] = []
    @State private var secondGroupSelection: [PhotosPickerItem] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Upload Photos")
                            .font(.tonaTitle1())
                            .foregroundColor(TonaColors.primaryDarkBlue)
                        
                        Text("Select photos for both groups to start processing")
                            .font(.tonaBody())
                            .foregroundColor(TonaColors.darkGray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // First Group Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("First Group")
                            .font(.tonaTitle2())
                            .foregroundColor(TonaColors.primaryDarkBlue)
                        
                        if viewModel.firstGroupImages.isEmpty {
                            UploadArea(
                                title: "Upload First Group",
                                subtitle: "Tap to select photos",
                                isDragOver: isFirstGroupDragOver
                            ) {
                                viewModel.selectFirstGroupPhotos()
                            }
                        } else {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                                ForEach(0..<viewModel.firstGroupImages.count, id: \.self) { index in
                                    PhotoCard(image: Image(uiImage: viewModel.firstGroupImages[index])) {
                                        // TODO: Implement photo preview/removal
                                        print("First group photo \(index) tapped")
                                    }
                                }
                                
                                // Add more button
                                PhotoCard(isPlaceholder: true) {
                                    viewModel.addMoreFirstGroupPhotos()
                                }
                            }
                        }
                    }
                    
                    // Second Group Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Second Group")
                            .font(.tonaTitle2())
                            .foregroundColor(TonaColors.primaryDarkBlue)
                        
                        if viewModel.secondGroupImages.isEmpty {
                            UploadArea(
                                title: "Upload Second Group",
                                subtitle: "Tap to select photos",
                                isDragOver: isSecondGroupDragOver
                            ) {
                                viewModel.selectSecondGroupPhotos()
                            }
                        } else {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                                ForEach(0..<viewModel.secondGroupImages.count, id: \.self) { index in
                                    PhotoCard(image: Image(uiImage: viewModel.secondGroupImages[index])) {
                                        // TODO: Implement photo preview/removal
                                        print("Second group photo \(index) tapped")
                                    }
                                }
                                
                                // Add more button
                                PhotoCard(isPlaceholder: true) {
                                    viewModel.addMoreSecondGroupPhotos()
                                }
                            }
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
                    
                    // Process Button
                    if viewModel.canStartProcessing {
                        TonaButton("Start Processing", style: .primary, isEnabled: !viewModel.isLoading) {
                            viewModel.startProcessing()
                        }
                        .padding(.top, 20)
                    }
                    
                    // Loading Indicator
                    if viewModel.isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Uploading and starting processing...")
                                .font(.tonaCaption())
                                .foregroundColor(TonaColors.darkGray)
                        }
                        .padding(.top, 20)
                    }
                }
                .padding(.horizontal, TonaSpacing.screenMargins)
                .padding(.bottom, 40)
            }
            .background(TonaColors.lightGray)
            .navigationBarHidden(true)
            .photosPicker(
                isPresented: $viewModel.isFirstGroupPickerPresented,
                selection: $firstGroupSelection,
                maxSelectionCount: 10,
                matching: .images
            )
            .onChange(of: firstGroupSelection) { selection in
                Task {
                    await viewModel.loadImages(from: selection, to: \PhotoUploadViewModel.firstGroupImages)
                }
            }
            .photosPicker(
                isPresented: $viewModel.isSecondGroupPickerPresented,
                selection: $secondGroupSelection,
                maxSelectionCount: 10,
                matching: .images
            )
            .onChange(of: secondGroupSelection) { selection in
                Task {
                    await viewModel.loadImages(from: selection, to: \PhotoUploadViewModel.secondGroupImages)
                }
            }
        }
    }
}

#Preview {
    PhotoUploadView()
}
