//
//  ContentView.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 2/27/26.
//

import SwiftUI
import SwiftData

private let baseURL = "http://localhost:5000"

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var loginRequests: [LoginRequest]
    private var loginRequest: LoginRequest? { loginRequests.first }

    // Register form fields
    @State private var regUsername = "Danny"
    @State private var regPassword = "KylePassword"
    @State private var regRole = "FrontDesk"
    @State private var regEmail = "kyle@email.com"
    @State private var regPhone = "666-666-6666"
    @State private var regStatusMessage = ""

    private let roles = ["FrontDesk", "ClinicalStaff"]

    var body: some View {
        VStack(spacing: 30) {
            VStack {
                Text("Register User")
                Button("Button") {
                    print(baseURL)
                    Task { await Register() }
                }
            }

            VStack {
                Text("Login User")
                Button("Button") {

                }
            }

            VStack {
                Text("Make Appointment")
                Button("Button") {

                }
            }

            VStack {
                Text("Get Appointment")
                Button("Button") {

                }
            }
        }
    }

    private func Register() async {
        let registerURL = "\(baseURL)/Auth/register"
        
        let requestBody = RegisterRequest(
            username: regUsername,
            password: regPassword,
            role: regRole,
            email: regEmail,
            phone: regPhone
        )

        guard let url = URL(string: registerURL) else { return }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            urlRequest.httpBody = try JSONEncoder().encode(requestBody)
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else { return }

            let body = String(data: data, encoding: .utf8) ?? ""

            switch httpResponse.statusCode {
            case 201:
                regStatusMessage = "Registration successful!"
            case 400, 409:
                regStatusMessage = body
            default:
                regStatusMessage = "Unexpected error (\(httpResponse.statusCode))"
            }
        } catch {
            regStatusMessage = "Request failed: \(error.localizedDescription)"
        }
        
        print(regStatusMessage)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: LoginRequest.self, inMemory: true)
}
