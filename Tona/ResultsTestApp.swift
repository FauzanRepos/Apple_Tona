import SwiftUI

// Removed @main to avoid conflict with AppDelegate
struct ResultsTestApp: App {
    var body: some Scene {
        WindowGroup {
            // Test with sample data
            TestResultsView()
        }
    }
}

struct TestResultsView: View {
    @StateObject private var appState = AppState()
    // TonaAPI is not ObservableObject, using it directly
    @StateObject private var resultVM: ResultVM
    
    init() {
        let api = TonaAPI()
        let state = AppState()
        _appState = StateObject(wrappedValue: state)
        _resultVM = StateObject(wrappedValue: ResultVM(tonaAPI: api, appState: state))
    }
    
    var body: some View {
        ResultsGridView(resultVM: resultVM, appState: appState)
            .onAppear {
                // Simulate loading results
                loadSampleResults()
            }
    }
    
    private func loadSampleResults() {
        // Create sample images for testing
        let sampleImages = (1...6).compactMap { index -> UIImage? in
            let size = CGSize(width: 300, height: 300)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            defer { UIGraphicsEndImageContext() }
            
            // Draw a gradient background
            let context = UIGraphicsGetCurrentContext()
            let colors = [
                UIColor.systemBlue.withAlphaComponent(0.8).cgColor,
                UIColor.systemPurple.withAlphaComponent(0.8).cgColor
            ]
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: nil
            )!
            
            context?.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
            
            // Add text
            let text = "Sample \(index)"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 40, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            text.draw(in: textRect, withAttributes: attributes)
            
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        
        // Simulate async loading
        resultVM.isLoadingResults = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            resultVM.results = sampleImages
            resultVM.isLoadingResults = false
        }
    }
}
