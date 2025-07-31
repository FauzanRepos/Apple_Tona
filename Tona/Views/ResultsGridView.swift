import SwiftUI

struct ResultsGridView: View {
    @ObservedObject var resultVM: ResultVM
    @ObservedObject var appState: AppState
    @State private var selectedImage: UIImage?
    @State private var showingDetailView = false
    @State private var showingShareSheet = false
    @State private var gridColumns = [GridItem(.adaptive(minimum: 120), spacing: 16)]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                TonaTheme.backgroundColor
                    .ignoresSafeArea()
                
                if resultVM.isLoadingResults {
                    // Loading state
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        
                        Text("Loading your processed images...")
                            .font(TonaTheme.font(size: 16))
                            .foregroundColor(TonaTheme.secondaryColor)
                        
                        if resultVM.downloadProgress > 0 {
                            ProgressView(value: resultVM.downloadProgress)
                                .frame(width: 200)
                                .tint(TonaTheme.accentColor)
                        }
                    }
                } else if !resultVM.results.isEmpty {
                    // Results grid
                    VStack(spacing: 0) {
                        // Header
                        Text("Your Processed Images")
                            .font(TonaTheme.font(size: 24, weight: .bold))
                            .foregroundColor(TonaTheme.primaryColor)
                            .padding(.top, 20)
                            .padding(.bottom, 16)
                        
                        // Image grid
                        ScrollView {
                            LazyVGrid(columns: gridColumns, spacing: 16) {
                                ForEach(Array(resultVM.results.enumerated()), id: \.offset) { index, image in
                                    ResultThumbnailView(
                                        image: image,
                                        index: index,
                                        onTap: {
                                            selectedImage = image
                                            showingDetailView = true
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 100) // Space for button
                        }
                        
                        Spacer()
                    }
                    
                    // Start Over button
                    VStack {
                        Spacer()
                        
                        Button(action: startOver) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Start Over")
                                    .font(TonaTheme.font(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(TonaTheme.dangerColor)
                            .cornerRadius(12)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 32)
                        }
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    TonaTheme.backgroundColor.opacity(0),
                                    TonaTheme.backgroundColor
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 120)
                        )
                    }
                } else if let error = resultVM.resultError {
                    // Error state
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(TonaTheme.dangerColor)
                        
                        Text("Failed to load results")
                            .font(TonaTheme.font(size: 20, weight: .semibold))
                            .foregroundColor(TonaTheme.primaryColor)
                        
                        Text(error)
                            .font(TonaTheme.font(size: 14))
                            .foregroundColor(TonaTheme.secondaryColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            Task {
                                await resultVM.fetchResults()
                            }
                        }) {
                            Text("Try Again")
                                .font(TonaTheme.font(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(TonaTheme.accentColor)
                                .cornerRadius(8)
                        }
                    }
                } else {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "photo.stack")
                            .font(.system(size: 48))
                            .foregroundColor(TonaTheme.secondaryColor)
                        
                        Text("No results available")
                            .font(TonaTheme.font(size: 20, weight: .semibold))
                            .foregroundColor(TonaTheme.primaryColor)
                        
                        Button(action: startOver) {
                            Text("Start Over")
                                .font(TonaTheme.font(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(TonaTheme.dangerColor)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingDetailView) {
                if let image = selectedImage {
                    ImageDetailView(
                        image: image,
                        onShare: {
                            showingShareSheet = true
                        },
                        onDismiss: {
                            showingDetailView = false
                        }
                    )
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let image = selectedImage {
                    ShareSheet(activityItems: [image])
                }
            }
        }
        .onAppear {
            // Fetch results if needed
            if resultVM.results.isEmpty && !resultVM.resultUrls.isEmpty {
                Task {
                    await resultVM.downloadResults(from: resultVM.resultUrls)
                }
            }
        }
    }
    
    private func startOver() {
        // Clear app state
        appState.reset()
        resultVM.clearResults()
        
        // Navigate back to upload screen
        // This should be handled by the parent view/navigation controller
        NotificationCenter.default.post(name: .navigateToUpload, object: nil)
    }
}

// MARK: - Result Thumbnail View
struct ResultThumbnailView: View {
    let image: UIImage
    let index: Int
    let onTap: () -> Void
    
    @State private var isLoaded = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Placeholder while loading
                if !isLoaded {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            ProgressView()
                                .scaleEffect(0.8)
                        )
                }
                
                // Thumbnail image
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 120, minHeight: 120)
                    .clipped()
                    .cornerRadius(12)
                    .shadow(color: TonaTheme.cardShadowColor.opacity(0.1), radius: 4, y: 2)
                    .opacity(isLoaded ? 1 : 0)
                    .animation(.easeIn(duration: 0.3), value: isLoaded)
                    .onAppear {
                        // Simulate async loading
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                            withAnimation {
                                isLoaded = true
                            }
                        }
                    }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Image Detail View
struct ImageDetailView: View {
    let image: UIImage
    let onShare: () -> Void
    let onDismiss: () -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                // Full resolution image
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let delta = value / lastScale
                                lastScale = value
                                scale = min(max(scale * delta, 1), 4)
                            }
                            .onEnded { _ in
                                lastScale = 1
                                if scale < 1.2 {
                                    withAnimation(.spring()) {
                                        scale = 1
                                        offset = .zero
                                    }
                                }
                            }
                    )
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { value in
                                if scale > 1 {
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                            }
                            .onEnded { _ in
                                lastOffset = offset
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.spring()) {
                            if scale > 1 {
                                scale = 1
                                offset = .zero
                                lastOffset = .zero
                            } else {
                                scale = 2
                            }
                        }
                    }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        onDismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        onShare()
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

// MARK: - Share Sheet
// Removed duplicate ShareSheet - using the one from ShareSheet.swift

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let navigateToUpload = Notification.Name("navigateToUpload")
}
