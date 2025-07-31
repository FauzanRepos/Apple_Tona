import SwiftUI

struct RootView: View {
    @State private var path: [AppScreen] = [.toneGallery]
    @StateObject private var appState = AppState()
    @StateObject private var toastManager = ToastManager()

    var body: some View {
        NavigationStack(path: $path) {
            screenView(for: path.last ?? .toneGallery)
                .navigationDestination(for: AppScreen.self) { screen in
                    screenView(for: screen)
                }
        }
        .environmentObject(appState)
        .environmentObject(toastManager)
        .toast($toastManager.currentToast)
        .fullScreenError($appState.currentError) {
            // Retry action based on current state
            appState.retryLastAction()
        }
        .onChange(of: toastManager.currentToast) { _, newValue in
            if newValue == nil {
                toastManager.processQueue()
            }
        }
    }

    @ViewBuilder
    func screenView(for screen: AppScreen) -> some View {
        switch screen {
case .toneGallery:
            BrandingSplashView(
                onGetStarted: { path.append(.uploadPreference) }
            )
            .navigationBarBackButtonHidden(true)
        case .uploadPreference:
            ToneCreationView(
                onToneCreated: { newTone in
                    let preview = UIImage()
                    let name = newTone.name
                    path.append(.toneResult(previewImage: preview, toneName: name))
                },
                onToneGenerated: { previewImage, toneName in
                    path.append(.toneResult(previewImage: previewImage, toneName: toneName))
                },
                isGenerating: .constant(false),
                showError: .constant(false)
            )
        case .toneResult(let previewImage, let toneName):
            ToneResultView(
                toneName: .constant(toneName),
                previewImage: previewImage,
                onApply: { path.append(.uploadPhoto(toneStyle: ToneStyle(name: toneName))) },
                onSave: { path = [.toneGallery] },
                onBack: { path = [.toneGallery] }
            )
        case .uploadPhoto(let toneStyle):
            PhotoEditorView(
                toneStyle: toneStyle,
                onAdjust: { image in path.append(.adjust(image: image)) }
            )
        case .adjust(let image):
            ManualEditView(
                inputImage: image,
                onDone: { path = [.toneGallery] },
                onBack: { path.removeLast() }
            )
        case .crop(_):
            Text("Crop Screen")
        }
    }
} 