//
//  ToneCreationView.swift
//  Tona
//
//  Created by Apple Dev on 08/07/25.
//

import SwiftUI
import PhotosUI

struct ToneCreationView: View {
    var onToneCreated: (ToneStyle) -> Void = { _ in }
    var onToneGenerated: ((UIImage, String) -> Void)? = nil
    @Binding var isGenerating: Bool
    @Binding var showError: Bool
    @StateObject private var viewModel = ToneCreationViewModel()
    @State private var selectedImages: [UIImage?] = []
    @State private var showPicker = false
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var showLoading = false
    @State private var toneName: String = ""
    @State private var showNameEmptyAlert = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer(minLength: 12)
                Text("Match your tone preference!")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(Color.tonaAccentBlue)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                Spacer(minLength: 8)
                // Gallery preview (show if at least 1 image is selected)
                if selectedImages.compactMap({ $0 }).count > 0 {
                    RotatedImageGallery(images: selectedImages.compactMap { $0 })
                        .padding(.top, 8)
                } else {
                    Spacer(minLength: 32)
                }
                Spacer(minLength: 24)
                // Only show the picker card if less than 6 images are selected
                if selectedImages.compactMap({ $0 }).count < 6 {
                    HStack {
                        Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color.tonaOffWhite)
                                .frame(width: 320, height: 320)
                                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                            Button(action: { showPicker = true }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.tonaAccentBlue)
                                        .frame(width: 100, height: 100)
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 48, height: 48)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        Spacer()
                    }
                }
                Spacer(minLength: 32)
            }
            .background(Color.tonaOffWhite.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .photosPicker(isPresented: $showPicker, selection: $pickerItems, matching: .images)
            .onChange(of: pickerItems) { _, _ in
                for item in pickerItems {
                    loadImage(item: item)
                }
                // Automatically analyze if more than 1 and up to 6 images are selected
                let count = selectedImages.compactMap { $0 }.count
                if count > 1 && count <= 6 {
                    analyzeTone()
                }
                // Limit to 6 images
                if selectedImages.count > 6 {
                    selectedImages = Array(selectedImages.prefix(6))
                }
            }
            // Custom loading overlay
            if showLoading {
                Color.black.opacity(0.08).ignoresSafeArea()
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .frame(width: 120, height: 120)
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.tonaDeepBlue))
                            .scaleEffect(2.0)
                    }
                    Text("Generating")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Color.tonaDeepBlue)
                }
            }
        }
        .alert("Name Required", isPresented: $showNameEmptyAlert) {
            Button("OK") { showNameEmptyAlert = false }
        } message: {
            Text("Please enter a name for your tone.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { showError = false }
        } message: {
            Text("Something went wrong. Please try again.")
        }
    }
    
    private func loadImage(item: PhotosPickerItem) {
        item.loadTransferable(type: Data.self) { result in
            switch result {
            case .success(let data):
                if let data, let uiImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        selectedImages.append(uiImage)
                    }
                }
            case .failure:
                break
            }
        }
    }
    
    private func analyzeTone() {
        showLoading = true
        Task {
            do {
                // Simulate FastAPI call
                let _ = try await FastAPIToneService.shared.uploadReferenceImages(selectedImages.compactMap { $0 })
                // Use the first image as a mock preview, tinted
                if let first = selectedImages.compactMap({ $0 }).first {
                    let preview = try await FastAPIToneService.shared.applyTone(to: first, toneID: "mock")
                    DispatchQueue.main.async {
                        showLoading = false
                        // Generate a default tone name
                        let defaultName = "My Tone \(Date().timeIntervalSince1970)"
                        onToneGenerated?(preview, defaultName)
                    }
                } else {
                    showLoading = false
                }
            } catch {
                showLoading = false
                showError = true
            }
        }
    }
    
    private func resetState() {
        selectedImages = []
        pickerItems = []
        showLoading = false
        showNameEmptyAlert = false
    }
}
