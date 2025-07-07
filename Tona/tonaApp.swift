//
//  tonaApp.swift
//  tona
//
//  Created by Apple Dev on 04/07/25.
//

import SwiftUI
import SwiftData

@main
struct tonaApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            // ContentView()
            SplashView(modelContainer: sharedModelContainer)
        }
        .modelContainer(sharedModelContainer)
    }
}
