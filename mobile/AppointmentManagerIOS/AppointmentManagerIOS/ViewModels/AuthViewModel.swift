//
//  AuthViewModel.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 3/11/26.
//

import Foundation
import SwiftData

@Observable
final class AuthViewModel {
    var token: String = ""
    var isLoggedIn: Bool = false
    var isLoading: Bool = false
    var statusMessage: String = ""

    private let apiService = APIService()

    /// Attempts auto-login using saved credentials from SwiftData
    func attemptAutoLogin(modelContext: ModelContext) async {
        let descriptor = FetchDescriptor<LoginRequest>()
        guard let savedLogin = try? modelContext.fetch(descriptor).first else {
            return
        }

        isLoading = true
        await login(username: savedLogin.username, password: savedLogin.password, modelContext: modelContext)
        isLoading = false
    }

    /// Registers a new user, then automatically logs them in on success
    func register(username: String, password: String, role: String, email: String, phone: String, modelContext: ModelContext) async {
        let request = RegisterRequest(
            username: username,
            password: password,
            role: role,
            email: email,
            phone: phone
        )

        isLoading = true
        do {
            let response = try await apiService.register(request)
            statusMessage = "Registration successful: \(response)"
            print(statusMessage)

            // Auto-login after successful registration
            await login(username: username, password: password, modelContext: modelContext)
        } catch {
            statusMessage = "Registration failed: \(error.localizedDescription)"
            print(statusMessage)
            isLoading = false
        }
    }

    func login(username: String, password: String, modelContext: ModelContext) async {
        let request = LoginRequest(
            username: username,
            password: password
        )

        isLoading = true
        do {
            let response = try await apiService.login(request)
            token = response.token
            isLoggedIn = true
            statusMessage = "Login successful"
            print(statusMessage)

            // Save credentials to SwiftData (replace any existing)
            let descriptor = FetchDescriptor<LoginRequest>()
            let existing = (try? modelContext.fetch(descriptor)) ?? []
            for item in existing {
                modelContext.delete(item)
            }
            let savedLogin = LoginRequest(username: username, password: password)
            modelContext.insert(savedLogin)
            try? modelContext.save()
        } catch {
            statusMessage = "Login failed: \(error.localizedDescription)"
            print(statusMessage)
        }
        isLoading = false
    }

    func logout(modelContext: ModelContext) {
        token = ""
        isLoggedIn = false
        statusMessage = ""

        // Clear saved credentials
        let descriptor = FetchDescriptor<LoginRequest>()
        let existing = (try? modelContext.fetch(descriptor)) ?? []
        for item in existing {
            modelContext.delete(item)
        }
        try? modelContext.save()
    }
}
