//
//  AppointmentViewModel.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 3/11/26.
//

import Foundation

@Observable
final class AppointmentViewModel {
    var appointments: [Appointment] = []
    var statusMessage: String = ""

    private let apiService = APIService()

    func fetchAppointments(token: String) async {
        do {
            appointments = try await apiService.getAppointments(token: token)
            let list = appointments.map { "\($0.type ?? "N/A") — \($0.date ?? "N/A")" }.joined(separator: "\n")
            statusMessage = "Fetched \(appointments.count) appointments:\n\(list)"
            print(statusMessage)
        } catch {
            statusMessage = "Fetch appointments failed: \(error.localizedDescription)"
            print(statusMessage)
        }
    }

    func createAppointment(patientId: String, date: String, type: String, token: String) async {
        let appointment = Appointment(
            patient_id: patientId,
            date: date,
            type: type
        )

        do {
            let response = try await apiService.createAppointment(appointment, token: token)
            statusMessage = "Appointment created: \(response)"
            print(statusMessage)
        } catch {
            statusMessage = "Create appointment failed: \(error.localizedDescription)"
            print(statusMessage)
        }
    }

    func fetchAppointments(patientId: String, token: String) async {
        do {
            appointments = try await apiService.getAppointments(patientId: patientId, token: token)
            let list = appointments.map { "\($0.type ?? "N/A") — \($0.date ?? "N/A")" }.joined(separator: "\n")
            statusMessage = "Fetched \(appointments.count) appointments for patient:\n\(list)"
            print(statusMessage)
        } catch {
            statusMessage = "Fetch appointments by patient failed: \(error.localizedDescription)"
            print(statusMessage)
        }
    }

    func updateAppointment(id: String, patientId: String, date: String, type: String, token: String) async {
        let appointment = Appointment(
            id: id,
            patient_id: patientId,
            date: date,
            type: type
        )

        do {
            let response = try await apiService.updateAppointment(id: id, appointment, token: token)
            statusMessage = "Appointment updated: \(response)"
            print(statusMessage)
        } catch {
            statusMessage = "Update appointment failed: \(error.localizedDescription)"
            print(statusMessage)
        }
    }

    func deleteAppointment(id: String, token: String) async {
        do {
            let response = try await apiService.deleteAppointment(id: id, token: token)
            statusMessage = "Appointment deleted: \(response)"
            print(statusMessage)
        } catch {
            statusMessage = "Delete appointment failed: \(error.localizedDescription)"
            print(statusMessage)
        }
    }
}
