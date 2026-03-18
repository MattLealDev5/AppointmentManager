//
//  RootView.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 3/16/26.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @State private var authVM = AuthViewModel()
    @State private var dataStore = DataStore()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            if authVM.isLoading && !authVM.isLoggedIn {
                // Auto-login in progress
                VStack(spacing: 16) {
                    ProgressView()
                        .controlSize(.large)
                    Text("Signing in...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else if authVM.isLoggedIn {
                MainTabView(authVM: authVM, dataStore: dataStore)
            } else {
                LoginView(authVM: authVM)
            }
        }
        .task {
            await authVM.attemptAutoLogin(modelContext: modelContext)
        }
        .onChange(of: authVM.isLoggedIn) { _, isLoggedIn in
            if isLoggedIn {
                Task {
                    await dataStore.refreshAll(token: authVM.token)
                }
            }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: LoginRequest.self, inMemory: true)
}
