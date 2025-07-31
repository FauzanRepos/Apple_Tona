//
//  UploadView.swift
//  Tona
//
//  Upload screen with two drop zones for photo selection
//

import SwiftUI
import PhotosUI

struct UploadView: View {
    @ObservedObject var uploadVM: UploadVM
    @EnvironmentObject var appState: AppState
    let onNavigateToProcessing: () -> Void
    
    @State private var tonedPhotos: [UIImage] = []
    @State private var newPhotos: [UIImage] = []
    @State private var showTonedPhotosPicker = false
    @State private var showNewPhotosPicker = false
    @State private var tonedPhotosItems: [PhotosPickerItem] = []
    @State private var newPhotosItems: [PhotosPickerItem] = []
    
    var canMatchTones: Bool {
        !tonedPhotos.isEmpty && !newPhotos.isEmpty
    }
    
    var body: some View {
        ZStack {
            Color.tonaOffWhite.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                Text("Upload Photos")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(Color.tonaDeepBlue)
                    .padding(.top, 20)
                
                // Drop zones container
                VStack(spacing: 16) {
                    // Your toned photos drop zone
                    PhotoDropZone(
                        title: "Your toned photos",
                        photos: tonedPhotos,
                        onTapDropZone: { showTonedPhotosPicker = true },
                        onRemovePhoto: { index in
                            tonedPhotos.remove(at: index)
                        }
                    )
                    
                    // New photos drop zone
                    PhotoDropZone(
                        title: "New photos",
                        photos: newPhotos,
                        onTapDropZone: { showNewPhotosPicker = true },
                        onRemovePhoto: { index in
                            newPhotos.remove(at: index)
                        }
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Match Tones button
                Button(action: matchTones) {
                    Text("Match Tones")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            canMatchTones ? Color.tonaDeepBlue : Color.gray.opacity(0.3)
                        )
                        .cornerRadius(12)
                        .animation(.easeInOut(duration: 0.2), value: canMatchTones)
                }
                .disabled(!canMatchTones || uploadVM.isUploading)
                .loadingButton(isLoading: uploadVM.isUploading, message: "Uploading...")
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .loadingOverlay(
            isLoading: uploadVM.isUploading,
            message: uploadVM.uploadProgress > 0 ? "Uploading... \(Int(uploadVM.uploadProgress * 100))%" : "Preparing upload...",
            progress: uploadVM.uploadProgress > 0 ? uploadVM.uploadProgress : nil
        )
        .navigationBarTitleDisplayMode(.inline)
        .photosPicker(
            isPresented: $showTonedPhotosPicker,
            selection: $tonedPhotosItems,
            maxSelectionCount: 10,
            matching: .images
        )
        .photosPicker(
            isPresented: $showNewPhotosPicker,
            selection: $newPhotosItems,
            maxSelectionCount: 10,
            matching: .images
        )
        .onChange(of: tonedPhotosItems) { _, items in
            loadImages(from: items, into: $tonedPhotos)
        }
        .onChange(of: newPhotosItems) { _, items in
            loadImages(from: items, into: $newPhotos)
        }
    }
    
    private func loadImages(from items: [PhotosPickerItem], into photos: Binding<[UIImage]>) {
        for item in items {
            item.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let data):
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            photos.wrappedValue.append(image)
                        }
                    }
                case .failure(let error):
                    print("Failed to load image: \(error)")
                }
            }
        }
    }
    
    private func matchTones() {
        Task {
            // Validate images
            guard !tonedPhotos.isEmpty else {
                appState.addError(AppError.validation(.noImagesSelected))
                appState.showInfo("Please add toned photos first")
                return
            }
            
            guard !newPhotos.isEmpty else {
                appState.addError(AppError.validation(.noImagesSelected))
                appState.showInfo("Please add new photos to apply tones to")
                return
            }
            
            // Upload toned photos (first group)
            uploadVM.setUploadType(.first)
            uploadVM.imagesToUpload = tonedPhotos
            await uploadVM.uploadImages()
            
            if uploadVM.uploadError != nil {
                return // Error already handled by uploadVM
            }
            
            // Upload new photos (second group)
            uploadVM.setUploadType(.second)
            uploadVM.imagesToUpload = newPhotos
            await uploadVM.uploadImages()
            
            if uploadVM.uploadError != nil {
                return // Error already handled by uploadVM
            }
            
            // Navigate to processing screen on success
            DispatchQueue.main.async {
                onNavigateToProcessing()
            }
        }
    }
}

// MARK: - Photo Drop Zone Component
struct PhotoDropZone: View {
    let title: String
    let photos: [UIImage]
    let onTapDropZone: () -> Void
    let onRemovePhoto: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color.tonaDeepBlue)
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.tonaDeepBlue.opacity(0.3), lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                    )
                    .frame(height: 140)
                
                if photos.isEmpty {
                    // Empty state
                    Button(action: onTapDropZone) {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 32))
                                .foregroundColor(Color.tonaDeepBlue.opacity(0.5))
                            
                            Text("Tap to add photos")
                                .font(.system(size: 16))
                                .foregroundColor(Color.tonaDeepBlue.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    // Photo thumbnails
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(photos.enumerated()), id: \.offset) { index, photo in
                                PhotoThumbnail(
                                    image: photo,
                                    onRemove: { onRemovePhoto(index) }
                                )
                            }
                            
                            // Add more button
                            Button(action: onTapDropZone) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.tonaDeepBlue.opacity(0.1))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(systemName: "plus")
                                            .font(.system(size: 24, weight: .medium))
                                            .foregroundColor(Color.tonaDeepBlue.opacity(0.6))
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                    }
                }
            }
        }
    }
}

// MARK: - Photo Thumbnail Component
struct PhotoThumbnail: View {
    let image: UIImage
    let onRemove: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(12)
            
            // Remove button
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.5))
                            .frame(width: 28, height: 28)
                    )
            }
            .offset(x: 8, y: -8)
        }
    }
}

// MARK: - Preview
struct UploadView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UploadView(
                uploadVM: UploadVM(
                    tonaAPI: TonaAPI(),
                    appState: AppState()
                ),
                onNavigateToProcessing: {}
            )
        }
    }
}
