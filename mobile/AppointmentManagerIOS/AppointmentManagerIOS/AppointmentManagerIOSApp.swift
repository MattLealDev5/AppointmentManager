//
//  AppointmentManagerIOSApp.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 2/27/26.
//

import SwiftUI
import SwiftData

@main
struct AppointmentManagerIOSApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LoginRequest.self,
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
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
