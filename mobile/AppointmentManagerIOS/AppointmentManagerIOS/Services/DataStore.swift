//
//  DataStore.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 3/18/26.
//

import Foundation

@Observable
final class DataStore {
    var patients: [Patient] = []
    var appointments: [Appointment] = []
    var taskItems: [TaskItem] = []
    var isLoading: Bool = false

    private let apiService = APIService()

    /// Fetches patients, appointments, and task items from the API and caches them
    func refreshAll(token: String) async {
        isLoading = true
        async let fetchedPatients = apiService.getPatients(token: token)
        async let fetchedAppointments = apiService.getAppointments(token: token)
        async let fetchedTaskItems = apiService.getTaskItems(token: token)

        do {
            let (p, a, t) = try await (fetchedPatients, fetchedAppointments, fetchedTaskItems)
            patients = p
            appointments = a
            taskItems = t
        } catch {
            print("DataStore refresh failed: \(error.localizedDescription)")
        }
        isLoading = false
    }

    /// Marks a task as completed via PUT and refreshes all data on success
    func completeTask(id: String, task: TaskItem, token: String) async -> Bool {
        var updatedTask = task
        updatedTask.status = "Completed"
        do {
            _ = try await apiService.updateTaskItem(id: id, updatedTask, token: token)
            await refreshAll(token: token)
            return true
        } catch {
            print("Complete task failed: \(error.localizedDescription)")
            return false
        }
    }

    /// Creates a new patient via POST and refreshes all data on success
    func createPatient(name: String, dateOfBirth: String, email: String, token: String) async -> Bool {
        let patient = Patient(name: name, date_of_birth: dateOfBirth, email: email)
        do {
            _ = try await apiService.createPatient(patient, token: token)
            await refreshAll(token: token)
            return true
        } catch {
            print("Create patient failed: \(error.localizedDescription)")
            return false
        }
    }

    /// Creates a new appointment via POST and refreshes all data on success
    func createAppointment(patientId: String, date: String, type: String, token: String) async -> Bool {
        let appointment = Appointment(patient_id: patientId, date: date, type: type)
        do {
            _ = try await apiService.createAppointment(appointment, token: token)
            await refreshAll(token: token)
            return true
        } catch {
            print("Create appointment failed: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Computed Properties

    /// Patients that have at least one appointment
    var activePatientsCount: Int {
        let patientIdsWithAppointments = Set(appointments.map { $0.patient_id })
        return patients.filter { patient in
            guard let id = patient.id else { return false }
            return patientIdsWithAppointments.contains(id.uuidString)
        }.count
    }

    var pendingTaskItems: [TaskItem] {
        taskItems.filter { $0.status == "Pending" }
    }

    var completedTaskItems: [TaskItem] {
        taskItems.filter { $0.status == "Completed" }
    }

    var overdueTaskItems: [TaskItem] {
        taskItems.filter { $0.status == "Overdue" }
    }

    /// Returns appointments that fall on today's date
    var todayAppointments: [Appointment] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())
        return appointments.filter { ($0.date ?? "").hasPrefix(todayString) }
    }

    /// Builds schedule items for today by matching appointments to patients
    var todayScheduleItems: [ScheduleItem] {
        todayAppointments.compactMap { appointment in
            guard let dateStr = appointment.date else { return nil }

            let patientName = patientName(for: appointment.patient_id)

            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            guard let date = inputFormatter.date(from: dateStr) else { return nil }

            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm"
            let time = timeFormatter.string(from: date)

            let periodFormatter = DateFormatter()
            periodFormatter.dateFormat = "a"
            let period = periodFormatter.string(from: date)

            return ScheduleItem(
                time: time,
                period: period,
                patientName: patientName,
                reason: appointment.type ?? "Appointment",
                status: .scheduled
            )
        }
    }

    /// Finds the patient name for a given patient_id string
    func patientName(for patientId: String) -> String {
        if let patient = patients.first(where: { $0.id?.uuidString == patientId }) {
            return patient.name
        }
        return "Unknown Patient"
    }
}
