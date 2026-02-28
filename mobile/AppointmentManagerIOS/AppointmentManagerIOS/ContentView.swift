//
//  ContentView.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 2/27/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    private var user: User? { users.first }

    var body: some View {
        NavigationSplitView {
            
        } detail: {
            Text("Select an item")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: User.self, inMemory: true)
}
