import SwiftUI

// MARK: - Loading Style
enum LoadingStyle {
    case overlay
    case inline
    case fullScreen
    case button
}

// MARK: - Custom Loading View
struct LoadingView: View {
    let message: String?
    let progress: Double?
    let style: LoadingStyle
    
    init(message: String? = nil, progress: Double? = nil, style: LoadingStyle = .overlay) {
        self.message = message
        self.progress = progress
        self.style = style
    }
    
    var body: some View {
        switch style {
        case .overlay:
            overlayLoading
        case .inline:
            inlineLoading
        case .fullScreen:
            fullScreenLoading
        case .button:
            buttonLoading
        }
    }
    
    // MARK: - Overlay Loading
    private var overlayLoading: some View {
        VStack(spacing: 16) {
            if let progress = progress {
                CircularProgressView(progress: progress)
                    .frame(width: 60, height: 60)
            } else {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .primary))
            }
            
            if let message = message {
                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 2)
        )
    }
    
    // MARK: - Inline Loading
    private var inlineLoading: some View {
        HStack(spacing: 12) {
            if let progress = progress {
                CircularProgressView(progress: progress)
                    .frame(width: 20, height: 20)
            } else {
                ProgressView()
                    .scaleEffect(0.8)
            }
            
            if let message = message {
                Text(message)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Full Screen Loading
    private var fullScreenLoading: some View {
        VStack(spacing: 24) {
            Spacer()
            
            if let progress = progress {
                CircularProgressView(progress: progress)
                    .frame(width: 80, height: 80)
            } else {
                ProgressView()
                    .scaleEffect(2.0)
                    .progressViewStyle(CircularProgressViewStyle(tint: .primary))
            }
            
            if let message = message {
                Text(message)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
    
    // MARK: - Button Loading
    private var buttonLoading: some View {
        HStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.7)
            
            if let message = message {
                Text(message)
                    .font(.system(size: 16, weight: .medium))
            }
        }
    }
}

// MARK: - Circular Progress View
struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Loading Overlay Modifier
struct LoadingOverlayModifier: ViewModifier {
    let isLoading: Bool
    let message: String?
    let progress: Double?
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading)
                .blur(radius: isLoading ? 2 : 0)
            
            if isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                LoadingView(
                    message: message,
                    progress: progress,
                    style: .overlay
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isLoading)
    }
}

// MARK: - Loading Button Modifier
struct LoadingButtonModifier: ViewModifier {
    let isLoading: Bool
    let message: String?
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .opacity(isLoading ? 0 : 1)
            
            if isLoading {
                LoadingView(
                    message: message,
                    style: .button
                )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

// MARK: - Skeleton Loading Modifier
struct SkeletonModifier: ViewModifier {
    let isLoading: Bool
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .redacted(reason: isLoading ? .placeholder : [])
            .overlay(
                isLoading ? shimmerOverlay : nil
            )
            .onAppear {
                if isLoading {
                    withAnimation(
                        .linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                    ) {
                        phase = 1
                    }
                }
            }
    }
    
    private var shimmerOverlay: some View {
        GeometryReader { geometry in
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.gray.opacity(0.3),
                    Color.gray.opacity(0.5),
                    Color.gray.opacity(0.3)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: geometry.size.width * 2)
            .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
            .mask(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
            )
        }
    }
}

// MARK: - View Extensions
extension View {
    func loadingOverlay(isLoading: Bool, message: String? = nil, progress: Double? = nil) -> some View {
        modifier(LoadingOverlayModifier(isLoading: isLoading, message: message, progress: progress))
    }
    
    func loadingButton(isLoading: Bool, message: String? = nil) -> some View {
        modifier(LoadingButtonModifier(isLoading: isLoading, message: message))
    }
    
    func skeleton(isLoading: Bool) -> some View {
        modifier(SkeletonModifier(isLoading: isLoading))
    }
}

// MARK: - Loading State Manager
class LoadingStateManager: ObservableObject {
    @Published private(set) var loadingStates: [String: (message: String?, progress: Double?)] = [:]
    
    func startLoading(for key: String, message: String? = nil) {
        loadingStates[key] = (message, nil)
    }
    
    func updateProgress(for key: String, progress: Double, message: String? = nil) {
        if let currentState = loadingStates[key] {
            loadingStates[key] = (message ?? currentState.message, progress)
        }
    }
    
    func stopLoading(for key: String) {
        loadingStates.removeValue(forKey: key)
    }
    
    func isLoading(for key: String) -> Bool {
        loadingStates[key] != nil
    }
    
    func getState(for key: String) -> (message: String?, progress: Double?)? {
        loadingStates[key]
    }
    
    var isAnyLoading: Bool {
        !loadingStates.isEmpty
    }
}
