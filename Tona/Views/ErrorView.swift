import SwiftUI

// MARK: - Full Screen Error View
struct ErrorView: View {
    let error: AppError
    let onRetry: (() -> Void)?
    let onDismiss: (() -> Void)?
    
    @Environment(\.colorScheme) var colorScheme
    
    private var iconName: String {
        switch error {
        case .network(.noConnection):
            return "wifi.slash"
        case .network:
            return "exclamationmark.icloud.fill"
        case .processing:
            return "exclamationmark.triangle.fill"
        case .validation:
            return "exclamationmark.circle.fill"
        case .storage:
            return "externaldrive.fill.exclamationmark"
        case .unknown:
            return "questionmark.circle.fill"
        }
    }
    
    private var iconColor: Color {
        switch error {
        case .network(.noConnection):
            return .orange
        case .network, .processing:
            return .red
        case .validation:
            return .yellow
        case .storage:
            return .purple
        case .unknown:
            return .gray
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Icon and Error Message
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 50))
                        .foregroundColor(iconColor)
                }
                .padding(.top, 60)
                
                // Error Title
                Text(errorTitle)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                // Error Description
                Text(error.errorDescription ?? "An unexpected error occurred")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 16) {
                if error.canRetry, let onRetry = onRetry {
                    Button(action: onRetry) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Try Again")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(iconColor)
                        )
                    }
                }
                
                if let onDismiss = onDismiss {
                    Button(action: onDismiss) {
                        Text(error.canRetry ? "Cancel" : "Close")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.gray.opacity(0.1))
                            )
                    }
                }
                
                // Additional Help Text
                if case .network(.noConnection) = error {
                    Text("Please check your internet connection and try again.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
    
    private var errorTitle: String {
        switch error {
        case .network(.noConnection):
            return "No Connection"
        case .network(.timeout):
            return "Request Timed Out"
        case .network(.serverError):
            return "Server Error"
        case .network:
            return "Network Error"
        case .processing(.jobFailed):
            return "Processing Failed"
        case .processing(.processingTimeout):
            return "Processing Timeout"
        case .processing:
            return "Processing Error"
        case .validation:
            return "Invalid Input"
        case .storage:
            return "Storage Error"
        case .unknown:
            return "Something Went Wrong"
        }
    }
}

// MARK: - Error View Modifier
struct ErrorViewModifier: ViewModifier {
    @Binding var error: AppError?
    let onRetry: (() -> Void)?
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: error?.isFatal == true ? 3 : 0)
                .disabled(error?.isFatal == true)
            
            if let error = error, error.isFatal {
                ErrorView(
                    error: error,
                    onRetry: onRetry,
                    onDismiss: {
                        self.error = nil
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: error?.id)
    }
}

// MARK: - View Extension
extension View {
    func fullScreenError(_ error: Binding<AppError?>, onRetry: (() -> Void)? = nil) -> some View {
        modifier(ErrorViewModifier(error: error, onRetry: onRetry))
    }
}

// MARK: - Error Sheet View (Alternative)
struct ErrorSheetView: View {
    let error: AppError
    let onRetry: (() -> Void)?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Error Icon
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                    .padding(.top, 40)
                
                // Error Message
                VStack(spacing: 12) {
                    Text("Error")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text(error.errorDescription ?? "An error occurred")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    if error.canRetry, let onRetry = onRetry {
                        Button(action: {
                            onRetry()
                            dismiss()
                        }) {
                            Text("Try Again")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.red)
                                )
                        }
                    }
                    
                    Button(action: { dismiss() }) {
                        Text("Dismiss")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.1))
                            )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
