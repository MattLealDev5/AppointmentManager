//
//  AuthViewModel.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 3/11/26.
//

import Foundation

@Observable
final class AuthViewModel {
    var token: String = ""
    var isLoggedIn: Bool = false
    var statusMessage: String = ""

    private let apiService = APIService()

    func register(username: String, password: String, role: String, email: String, phone: String) async {
        let request = RegisterRequest(
            username: username,
            password: password,
            role: role,
            email: email,
            phone: phone
        )

        do {
            let response = try await apiService.register(request)
            statusMessage = "Registration successful: \(response)"
            print(statusMessage)
        } catch {
            statusMessage = "Registration failed: \(error.localizedDescription)"
            print(statusMessage)
        }
    }

    func login(username: String, password: String) async {
        let request = LoginRequest(
            username: username,
            password: password
        )

        do {
            let response = try await apiService.login(request)
            token = response.token
            isLoggedIn = true
            statusMessage = "Login successful"
            print(statusMessage)
        } catch {
            statusMessage = "Login failed: \(error.localizedDescription)"
            print(statusMessage)
        }
    }
}
