import SwiftUI
import SwiftData

struct SplashView: View {
    @State private var isActive = false
    let modelContainer: ModelContainer

    var body: some View {
        if isActive {
            ContentView()
                .transition(.opacity)
        } else {
            ZStack {
                // Color(red: 1.0, green: 0.984, blue: 0.957) // #FFFBF4
                Color(uiColor: UIColor(red: 1.0, green: 0.984, blue: 0.957, alpha: 1.0))
                    .ignoresSafeArea()
                Image("Icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
            }
            .onAppear {
                // Delay for 1.5 seconds, then show main content
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}
