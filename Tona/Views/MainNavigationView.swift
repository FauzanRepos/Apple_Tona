import SwiftUI

enum NavigationScreen {
    case upload
    case processing
    case results
}

struct MainNavigationView: View {
    @StateObject private var appState = AppState()
    private let tonaAPI = TonaAPI()
    @State private var currentScreen: NavigationScreen = .upload
    
    var body: some View {
        NavigationView {
            ZStack {
                switch currentScreen {
                case .upload:
                    UploadView(
                        uploadVM: UploadVM(tonaAPI: tonaAPI, appState: appState),
                        onNavigateToProcessing: {
                            currentScreen = .processing
                        }
                    )
                    .transition(.move(edge: .leading))
                    
                case .processing:
                    ProcessingView(
                        viewModel: ProcessingVM(tonaAPI: tonaAPI, appState: appState)
                    )
                    .transition(.move(edge: .trailing))
                    .onReceive(appState.$processingState) { state in
                        if case .completed = state {
                            // Navigate to results when processing completes
                            withAnimation {
                                currentScreen = .results
                            }
                        }
                    }
                    
                case .results:
                    ResultsGridView(
                        resultVM: ResultVM(tonaAPI: tonaAPI, appState: appState),
                        appState: appState
                    )
                    .transition(.move(edge: .trailing))
                    .onReceive(NotificationCenter.default.publisher(for: .navigateToUpload)) { _ in
                        // Navigate back to upload when "Start Over" is pressed
                        withAnimation {
                            currentScreen = .upload
                        }
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: currentScreen)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MainNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        MainNavigationView()
    }
}
