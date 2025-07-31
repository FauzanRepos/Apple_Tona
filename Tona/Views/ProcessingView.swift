import SwiftUI

struct ProcessingView: View {
    @ObservedObject var viewModel: ProcessingVM
    @State private var isAnimating = false
    @State private var useCircularProgress = true
    
    var body: some View {
        VStack(spacing: 30) {
            // Progress Indicator (Circular or Linear)
            if useCircularProgress {
                // Large Circular Progress Indicator
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(
                            Color.gray.opacity(0.2),
                            lineWidth: 15
                        )
                        .frame(width: 150, height: 150)
                    
                    // Progress circle
                    Circle()
                        .trim(from: 0, to: viewModel.progress)
                        .stroke(
                            TonaTheme.accentColor,
                            style: StrokeStyle(
                                lineWidth: 15,
                                lineCap: .round
                            )
                        )
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: viewModel.progress)
                    
                    // Progress percentage text
                    Text("\(Int(viewModel.progress * 100))%")
                        .font(TonaTheme.font(size: 32, weight: .bold))
                        .foregroundColor(TonaTheme.primaryColor)
                }
            } else {
                // Linear Progress Indicator
                VStack(spacing: 12) {
                    Text("\(Int(viewModel.progress * 100))%")
                        .font(TonaTheme.font(size: 24, weight: .bold))
                        .foregroundColor(TonaTheme.primaryColor)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 20)
                            
                            // Progress
                            RoundedRectangle(cornerRadius: 10)
                                .fill(TonaTheme.accentColor)
                                .frame(width: geometry.size.width * viewModel.progress, height: 20)
                                .animation(.easeInOut(duration: 0.5), value: viewModel.progress)
                        }
                    }
                    .frame(height: 20)
                    .frame(maxWidth: 300)
                }
            }
            
            // Step text
            VStack(spacing: 8) {
                Text(getStepText())
                    .font(TonaTheme.font(size: 20, weight: .semibold))
                    .foregroundColor(TonaTheme.primaryColor)
                    .multilineTextAlignment(.center)
                
                if let statusMessage = viewModel.statusMessage {
                    Text(statusMessage)
                        .font(TonaTheme.font(size: 14))
                        .foregroundColor(TonaTheme.secondaryColor)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal)
            
            // Cancel button
            Button(action: {
                Task {
                    await viewModel.cancelProcessing()
                }
            }) {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                    Text("Cancel Processing")
                        .font(TonaTheme.font(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.red)
                .cornerRadius(25)
            }
            .disabled(!viewModel.isProcessing)
            .opacity(viewModel.isProcessing ? 1.0 : 0.5)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(TonaTheme.backgroundColor)
                .shadow(color: TonaTheme.cardShadowColor.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .onAppear {
            startPolling()
        }
        .onDisappear {
            // Cancel any ongoing tasks when view disappears
            Task {
                if viewModel.isProcessing {
                    await viewModel.cancelProcessing()
                }
            }
        }
    }
    
    private func getStepText() -> String {
        let currentStep = Int(viewModel.progress * 8) + 1
        let totalSteps = 8
        
        // More descriptive step messages based on progress
        switch currentStep {
        case 1:
            return "Analyzing images..."
        case 2:
            return "Extracting tone characteristics..."
        case 3...6:
            return "Editing image \(currentStep - 2) of \(totalSteps - 2)"
        case 7:
            return "Finalizing edits..."
        case 8:
            return "Processing complete!"
        default:
            return "Processing..."
        }
    }
    
    private func startPolling() {
        Task {
            await pollStatus()
        }
    }
    
    private func pollStatus() async {
        while viewModel.isProcessing {
            // Use async let for concurrent execution if needed
            async let statusCheck: Void = viewModel.checkStatus()
            async let delay: Void = Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            
            // Wait for both to complete
            _ = try? await (statusCheck, delay)
        }
    }
}

struct ProcessingView_Previews: PreviewProvider {
    static var previews: some View {
        ProcessingView(viewModel: ProcessingVM(tonaAPI: TonaAPI(), appState: AppState()))
    }
}

