//
//  APIService.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 3/11/26.
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let statusCode, let message):
            return "Server error (\(statusCode)): \(message)"
        }
    }
}

@Observable
final class APIService {
    private let baseURL = Secrets.apiBaseURL

    // MARK: - Auth

    /// POST /Auth/register — Register a new user account
    func register(_ request: RegisterRequest) async throws -> String {
        let data = try await post(path: "/Auth/register", body: request)
        return String(data: data, encoding: .utf8) ?? "Registration successful"
    }

    /// POST /Auth/login — Authenticate and receive a JWT token
    func login(_ request: LoginRequest) async throws -> LoginResponse {
        let data = try await post(path: "/Auth/login", body: request)
        return try JSONDecoder().decode(LoginResponse.self, from: data)
    }

    // MARK: - Patients

    /// POST /Patient — Create a new patient (requires JWT)
    func createPatient(_ patient: Patient, token: String) async throws -> String {
        let data = try await post(path: "/Patient", body: patient, token: token)
        return String(data: data, encoding: .utf8) ?? "Patient created"
    }

    /// GET /Patient — Retrieve all patients (requires JWT)
    func getPatients(token: String) async throws -> [Patient] {
        let data = try await get(path: "/Patient", token: token)
        return try JSONDecoder().decode([Patient].self, from: data)
    }

    /// GET /Patient/{id} — Retrieve a single patient by ID (requires JWT)
    func getPatient(id: String, token: String) async throws -> [Patient] {
        let data = try await get(path: "/Patient/\(id)", token: token)
        return try JSONDecoder().decode([Patient].self, from: data)
    }

    /// PUT /Patient/{id} — Update a patient by ID (requires JWT)
    func updatePatient(id: String, _ patient: Patient, token: String) async throws -> String {
        let data = try await put(path: "/Patient/\(id)", body: patient, token: token)
        return String(data: data, encoding: .utf8) ?? "Patient updated"
    }

    // MARK: - Private Helpers

    private func post<T: Encodable>(path: String, body: T, token: String? = nil) async throws -> Data {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: message)
        }

        return data
    }

    private func put<T: Encodable>(path: String, body: T, token: String? = nil) async throws -> Data {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: message)
        }

        return data
    }

    private func get(path: String, token: String? = nil) async throws -> Data {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: message)
        }

        return data
    }
}
