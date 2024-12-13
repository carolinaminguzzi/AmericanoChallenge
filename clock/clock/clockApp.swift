//
//  clockApp.swift
//  clock
//
//  Created by carolina minguzzi on 13/12/24.
//

import SwiftUI
import SwiftData

@main
struct clockApp: App {
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
            ClockAppView()
        }
        .modelContainer(sharedModelContainer)
    }
}
