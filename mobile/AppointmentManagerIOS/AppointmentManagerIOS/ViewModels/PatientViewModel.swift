//
//  PatientViewModel.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 3/11/26.
//

import Foundation

@Observable
final class PatientViewModel {
    var patients: [Patient] = []
    var statusMessage: String = ""

    private let apiService = APIService()

    func createPatient(name: String, dateOfBirth: String, email: String, token: String) async {
        let patient = Patient(
            name: name,
            date_of_birth: dateOfBirth,
            email: email
        )

        do {
            let response = try await apiService.createPatient(patient, token: token)
            statusMessage = "Patient created: \(response)"
            print(statusMessage)
        } catch {
            statusMessage = "Create patient failed: \(error.localizedDescription)"
            print(statusMessage)
        }
    }

    func fetchPatients(token: String) async {
        do {
            patients = try await apiService.getPatients(token: token)
            let patientList = patients.map { "\($0.name) — \($0.email)" }.joined(separator: "\n")
            statusMessage = "Fetched \(patients.count) patients:\n\(patientList)"
            print(statusMessage)
        } catch {
            statusMessage = "Fetch patients failed: \(error.localizedDescription)"
            print(statusMessage)
        }
    }

    func fetchPatient(id: String, token: String) async {
        do {
            let results = try await apiService.getPatient(id: id, token: token)
            if let patient = results.first {
                statusMessage = "Patient: \(patient.name) — \(patient.email) — DOB: \(patient.date_of_birth)"
            } else {
                statusMessage = "No patient found with that ID"
            }
            print(statusMessage)
        } catch {
            statusMessage = "Fetch patient failed: \(error.localizedDescription)"
            print(statusMessage)
        }
    }

    func updatePatient(id: String, name: String, dateOfBirth: String, email: String, token: String) async {
        let patient = Patient(
            name: name,
            date_of_birth: dateOfBirth,
            email: email
        )

        do {
            let response = try await apiService.updatePatient(id: id, patient, token: token)
            statusMessage = "Patient updated: \(response)"
            print(statusMessage)
        } catch {
            statusMessage = "Update patient failed: \(error.localizedDescription)"
            print(statusMessage)
        }
    }
}
