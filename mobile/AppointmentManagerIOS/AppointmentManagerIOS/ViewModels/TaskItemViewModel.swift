//
//  TaskItemViewModel.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 3/11/26.
//

import Foundation

@Observable
final class TaskItemViewModel {
    var taskItems: [TaskItem] = []
    var statusMessage: String = ""

    private let apiService = APIService()

    func fetchTaskItems(token: String) async {
        do {
            taskItems = try await apiService.getTaskItems(token: token)
            let list = taskItems.map { "\($0.status) — \($0.priority)" }.joined(separator: "\n")
            statusMessage = "Fetched \(taskItems.count) task items:\n\(list)"
            print(statusMessage)
        } catch {
            statusMessage = "Fetch task items failed: \(error.localizedDescription)"
            print(statusMessage)
        }
    }

    func fetchTaskItems(status: String, token: String) async {
        do {
            taskItems = try await apiService.getTaskItems(status: status, token: token)
            let list = taskItems.map { "\($0.status) — \($0.priority)" }.joined(separator: "\n")
            statusMessage = "Fetched \(taskItems.count) task items with status '\(status)':\n\(list)"
            print(statusMessage)
        } catch {
            statusMessage = "Fetch task items by status failed: \(error.localizedDescription)"
            print(statusMessage)
        }
    }

    func updateTaskItem(id: String, appointmentId: String, status: String, priority: String, token: String) async {
        guard let apptUUID = UUID(uuidString: appointmentId) else {
            statusMessage = "Invalid appointment ID format"
            print(statusMessage)
            return
        }

        let taskItem = TaskItem(
            id: id,
            appointment_id: apptUUID,
            status: status,
            priority: priority
        )

        do {
            let response = try await apiService.updateTaskItem(id: id, taskItem, token: token)
            statusMessage = "Task item updated: \(response)"
            print(statusMessage)
        } catch {
            statusMessage = "Update task item failed: \(error.localizedDescription)"
            print(statusMessage)
        }
    }

    func markTaskItemOverdue(id: String, token: String) async {
        do {
            let response = try await apiService.markTaskItemOverdue(id: id, token: token)
            statusMessage = "Task item marked overdue: \(response)"
            print(statusMessage)
        } catch {
            statusMessage = "Mark overdue failed: \(error.localizedDescription)"
            print(statusMessage)
        }
    }
}
