//
//  ContentView.swift
//  Tona
//
//  Created by Apple Dev on 06/09/25.
//

import SwiftUI

struct ContentView: View {
    @State private var currentView: AppView = .photoUpload
    
    enum AppView {
        case photoUpload
        case processing
        case results
    }
    
    var body: some View {
        Group {
            switch currentView {
            case .photoUpload:
                PhotoUploadView()
            case .processing:
                ProcessingView()
            case .results:
                ResultsView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToProcessing)) { _ in
            currentView = .processing
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToResults)) { _ in
            currentView = .results
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToUpload)) { _ in
            currentView = .photoUpload
        }
    }
}

// MARK: - Navigation Notifications
extension Notification.Name {
    static let navigateToProcessing = Notification.Name("navigateToProcessing")
    static let navigateToResults = Notification.Name("navigateToResults")
    static let navigateToUpload = Notification.Name("navigateToUpload")
}

#Preview {
    ContentView()
}
