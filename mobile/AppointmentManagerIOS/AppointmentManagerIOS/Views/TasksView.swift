//
//  TasksView.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 3/16/26.
//

import SwiftUI

struct TasksView: View {
    var dataStore: DataStore = DataStore()
    var authVM: AuthViewModel = AuthViewModel()
    @State private var taskToComplete: TaskItem? = nil
    @State private var showingConfirmation = false

    private var allTasks: [TaskItem] { dataStore.taskItems }

    private var pendingTasks: [TaskItem] {
        allTasks.filter { $0.status != "Completed" }
    }

    private var completedTasks: [TaskItem] {
        allTasks.filter { $0.status == "Completed" }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: - Header
                Text("Clinical Tasks")
                    .font(.title2)
                    .fontWeight(.bold)

                // MARK: - Pending Tasks
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .foregroundStyle(.orange)
                        Text("Pending Tasks")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    if pendingTasks.isEmpty {
                        Text("No pending tasks")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(pendingTasks) { task in
                                PendingTaskRow(
                                    task: task,
                                    patientName: dataStore.patientName(for: task.appointment_id.uuidString)
                                ) {
                                    taskToComplete = task
                                    showingConfirmation = true
                                }
                                if task.id != pendingTasks.last?.id {
                                    Divider()
                                        .padding(.leading, 16)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // MARK: - Completed Tasks
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Completed Tasks")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    if completedTasks.isEmpty {
                        Text("No completed tasks")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(completedTasks) { task in
                                CompletedTaskRow(
                                    task: task,
                                    patientName: dataStore.patientName(for: task.appointment_id.uuidString)
                                )
                                if task.id != completedTasks.last?.id {
                                    Divider()
                                        .padding(.leading, 16)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 12)
                .background(Color.green.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green.opacity(0.2), lineWidth: 1)
                )
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .alert("Complete Task", isPresented: $showingConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Complete", role: .destructive) {
                guard let task = taskToComplete, let id = task.id else { return }
                Task {
                    _ = await dataStore.completeTask(id: id, task: task, token: authVM.token)
                }
            }
        } message: {
            Text("Are you sure you want to mark this task as completed?")
        }
    }
}

// MARK: - Pending Task Row

struct PendingTaskRow: View {
    let task: TaskItem
    var patientName: String = "Unknown Patient"
    var onComplete: () -> Void = {}

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Left side: task info
            VStack(alignment: .leading, spacing: 4) {
                Text(task.status)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(patientName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Right side: priority badge + complete button
            VStack(alignment: .trailing, spacing: 8) {
                Text(task.priority.lowercased())
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(priorityColor(task.priority))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(priorityColor(task.priority).opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Button(action: onComplete) {
                    Text("Complete")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func priorityColor(_ priority: String) -> Color {
        switch priority {
        case "High": return .red
        case "Medium": return .yellow
        case "Low": return .blue
        default: return .gray
        }
    }
}

// MARK: - Completed Task Row

struct CompletedTaskRow: View {
    let task: TaskItem
    var patientName: String = "Unknown Patient"

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.body)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.status)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .strikethrough(true, color: .secondary)

                Text(patientName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    TasksView(dataStore: DataStore(), authVM: AuthViewModel())
}
