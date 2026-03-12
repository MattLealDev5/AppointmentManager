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

private struct EmptyBody: Encodable {}

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

    // MARK: - Appointments

    /// GET /Appointment — Retrieve all appointments (requires JWT)
    func getAppointments(token: String) async throws -> [Appointment] {
        let data = try await get(path: "/Appointment", token: token)
        return try JSONDecoder().decode([Appointment].self, from: data)
    }

    /// POST /Appointment — Create a new appointment (requires JWT)
    func createAppointment(_ appointment: Appointment, token: String) async throws -> String {
        let data = try await post(path: "/Appointment", body: appointment, token: token)
        return String(data: data, encoding: .utf8) ?? "Appointment created"
    }

    /// GET /Appointment/{patient_id} — Retrieve appointments by patient ID (requires JWT)
    func getAppointments(patientId: String, token: String) async throws -> [Appointment] {
        let data = try await get(path: "/Appointment/\(patientId)", token: token)
        return try JSONDecoder().decode([Appointment].self, from: data)
    }

    /// PUT /Appointment/{id} — Update an appointment by ID (requires JWT)
    func updateAppointment(id: String, _ appointment: Appointment, token: String) async throws -> String {
        let data = try await put(path: "/Appointment/\(id)", body: appointment, token: token)
        return String(data: data, encoding: .utf8) ?? "Appointment updated"
    }

    /// DELETE /Appointment/{id} — Delete an appointment by ID (requires JWT)
    func deleteAppointment(id: String, token: String) async throws -> String {
        let data = try await delete(path: "/Appointment/\(id)", token: token)
        return String(data: data, encoding: .utf8) ?? "Appointment deleted"
    }

    // MARK: - TaskItems

    /// GET /TaskItem — Retrieve all task items (requires JWT)
    func getTaskItems(token: String) async throws -> [TaskItem] {
        let data = try await get(path: "/TaskItem", token: token)
        return try JSONDecoder().decode([TaskItem].self, from: data)
    }

    /// GET /TaskItem/{status} — Retrieve task items by status (requires JWT)
    func getTaskItems(status: String, token: String) async throws -> [TaskItem] {
        let data = try await get(path: "/TaskItem/\(status)", token: token)
        return try JSONDecoder().decode([TaskItem].self, from: data)
    }

    /// PUT /TaskItem/{id} — Update a task item by ID (requires JWT)
    func updateTaskItem(id: String, _ taskItem: TaskItem, token: String) async throws -> String {
        let data = try await put(path: "/TaskItem/\(id)", body: taskItem, token: token)
        return String(data: data, encoding: .utf8) ?? "TaskItem updated"
    }

    /// PUT /TaskItem/markOverdue/{id} — Mark a task item as overdue (requires JWT)
    func markTaskItemOverdue(id: String, token: String) async throws -> String {
        let data = try await put(path: "/TaskItem/markOverdue/\(id)", body: EmptyBody(), token: token)
        return String(data: data, encoding: .utf8) ?? "TaskItem marked overdue"
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

    private func delete(path: String, token: String? = nil) async throws -> Data {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

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
