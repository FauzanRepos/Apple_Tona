import XCTest
import SnapshotTesting
@testable import Tona

class SnapshotTests: XCTestCase {

    func testUploadViewSnapshotLightMode() {
        let uploadVM = UploadVM(tonaAPI: TonaAPI(), appState: AppState())
        let uploadView = UploadView(uploadVM: uploadVM, onNavigateToProcessing: {})
        let hostingController = UIHostingController(rootView: uploadView)
        
        assertSnapshot(matching: hostingController, as: .image(on: .iPhoneSe))
    }

    func testUploadViewSnapshotDarkMode() {
        let uploadVM = UploadVM(tonaAPI: TonaAPI(), appState: AppState())
        let uploadView = UploadView(uploadVM: uploadVM, onNavigateToProcessing: {})
        let hostingController = UIHostingController(rootView: uploadView)
        
        // Set environment to dark mode
        hostingController.overrideUserInterfaceStyle = .dark

        assertSnapshot(matching: hostingController, as: .image(on: .iPhoneSe))
    }
}
