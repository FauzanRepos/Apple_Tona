//
//  ToneCollectionView.swift
//  Tona
//
//  Created by Apple Dev on 08/07/25.
//

import SwiftUI

struct ToneCollectionView: View {
    @StateObject private var viewModel = ToneCollectionViewModel()
    @State private var showAddSheet = false
    @State private var showPhotoEditor = false
    @State private var selectedTone: ToneStyle? = nil
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.tonaOffWhite.ignoresSafeArea()
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Collection")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color.tonaDeepBlue)
                        Spacer()
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                    
                    // List of Tone Cards
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView("Loading tones...")
                            .padding()
                        Spacer()
                    } else if viewModel.toneStyles.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "rectangle.stack.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Color.tonaDeepBlue.opacity(0.15))
                            Text("No Tone Styles Yet")
                                .font(.title3.weight(.semibold))
                                .foregroundColor(Color.tonaDeepBlue.opacity(0.7))
                            Text("Create your first tone style to get started.")
                                .foregroundColor(Color.tonaDeepBlue.opacity(0.5))
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                ForEach(viewModel.toneStyles, id: \.id) { toneStyle in
                                    ToneCard(toneStyle: toneStyle) {
                                        selectedTone = toneStyle
                                        showPhotoEditor = true
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 80)
                        }
                    }
                }
                // Floating Add Button
                Button(action: { showAddSheet = true }) {
                    ZStack {
                        Circle()
                            .fill(Color.tonaAccentBlue)
                            .frame(width: 64, height: 64)
                            .shadow(color: Color.tonaAccentBlue.opacity(0.18), radius: 10, y: 4)
                        Image(systemName: "plus")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(28)
                .sheet(isPresented: $showAddSheet) {
                    ToneCreationSheet(onToneCreated: { newTone in
                        viewModel.toneStyles.append(newTone)
                        showAddSheet = false
                    })
                }
                // Navigation to PhotoEditorView
                NavigationLink(
                    destination: selectedTone.map { PhotoEditorView(toneStyle: $0) },
                    isActive: $showPhotoEditor
                ) {
                    EmptyView()
                }
            }
        }
    }
}

struct ToneCard: View {
    let toneStyle: ToneStyle
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 18) {
                if let previewData = toneStyle.previewImageData,
                   let previewImage = UIImage(data: previewData) {
                    Image(uiImage: previewImage)
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .frame(width: 72, height: 72)
                        .clipped()
                        .cornerRadius(16)
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.tonaSoftGray)
                        .frame(width: 72, height: 72)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 28))
                                .foregroundColor(Color.tonaDeepBlue.opacity(0.18))
                        )
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(toneStyle.name)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(Color.tonaDeepBlue)
                        .lineLimit(1)
                    Text(toneStyle.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(Color.tonaDeepBlue.opacity(0.5))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.tonaDeepBlue.opacity(0.18))
            }
            .padding(18)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.tonaCardShadow, radius: 6, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Sheet for creating a new tone
struct ToneCreationSheet: View {
    var onToneCreated: (ToneStyle) -> Void
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ToneCreationViewModel()
    @State private var isGenerating = false
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            ToneCreationView(
                onToneCreated: { newTone in
                    onToneCreated(newTone)
                    dismiss()
                },
                isGenerating: $isGenerating,
                showError: $showError
            )
            .navigationTitle("Create Tone")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
