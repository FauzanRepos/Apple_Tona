import SwiftUI

// MARK: - Toast Type
enum ToastType {
    case success
    case error
    case warning
    case info
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .warning: return .orange
        case .info: return .blue
        }
    }
}

// MARK: - Toast Configuration
struct ToastConfiguration: Identifiable, Equatable {
    let id = UUID()
    let type: ToastType
    let message: String
    let duration: TimeInterval
    let action: (() -> Void)?
    let actionTitle: String?
    
    static func == (lhs: ToastConfiguration, rhs: ToastConfiguration) -> Bool {
        lhs.id == rhs.id
    }
    
    init(
        type: ToastType,
        message: String,
        duration: TimeInterval = 3.0,
        action: (() -> Void)? = nil,
        actionTitle: String? = nil
    ) {
        self.type = type
        self.message = message
        self.duration = duration
        self.action = action
        self.actionTitle = actionTitle
    }
}

// MARK: - Toast View
struct ToastView: View {
    let configuration: ToastConfiguration
    @State private var isShowing = false
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: configuration.type.icon)
                .font(.system(size: 20))
                .foregroundColor(configuration.type.color)
            
            Text(configuration.message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 0)
            
            if let actionTitle = configuration.actionTitle,
               let action = configuration.action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(configuration.type.color)
                }
            }
            
            Button(action: dismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
        .offset(y: isShowing ? 0 : -100)
        .opacity(isShowing ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isShowing)
        .onAppear {
            withAnimation {
                isShowing = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + configuration.duration) {
                dismiss()
            }
        }
    }
    
    private func dismiss() {
        withAnimation {
            isShowing = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

// MARK: - Toast Modifier
struct ToastModifier: ViewModifier {
    @Binding var toast: ToastConfiguration?
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            VStack {
                if let toast = toast {
                    ToastView(
                        configuration: toast,
                        onDismiss: {
                            self.toast = nil
                        }
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                Spacer()
            }
            .animation(.spring(), value: toast?.id)
        }
    }
}

// MARK: - View Extension
extension View {
    func toast(_ toast: Binding<ToastConfiguration?>) -> some View {
        modifier(ToastModifier(toast: toast))
    }
}

// MARK: - Toast Manager
class ToastManager: ObservableObject {
    @Published var currentToast: ToastConfiguration?
    private var toastQueue: [ToastConfiguration] = []
    
    func show(_ toast: ToastConfiguration) {
        if currentToast == nil {
            currentToast = toast
        } else {
            toastQueue.append(toast)
        }
    }
    
    func showSuccess(_ message: String, action: (() -> Void)? = nil, actionTitle: String? = nil) {
        show(ToastConfiguration(
            type: .success,
            message: message,
            action: action,
            actionTitle: actionTitle
        ))
    }
    
    func showError(_ message: String, action: (() -> Void)? = nil, actionTitle: String? = nil) {
        show(ToastConfiguration(
            type: .error,
            message: message,
            duration: 5.0, // Longer duration for errors
            action: action,
            actionTitle: actionTitle
        ))
    }
    
    func showWarning(_ message: String, action: (() -> Void)? = nil, actionTitle: String? = nil) {
        show(ToastConfiguration(
            type: .warning,
            message: message,
            duration: 4.0,
            action: action,
            actionTitle: actionTitle
        ))
    }
    
    func showInfo(_ message: String, action: (() -> Void)? = nil, actionTitle: String? = nil) {
        show(ToastConfiguration(
            type: .info,
            message: message,
            action: action,
            actionTitle: actionTitle
        ))
    }
    
    func processQueue() {
        if !toastQueue.isEmpty {
            currentToast = toastQueue.removeFirst()
        }
    }
}
