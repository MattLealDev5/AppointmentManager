//
//  TasksView.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 3/16/26.
//

import SwiftUI

struct TasksView: View {
    var taskDisplayItems: [TaskDisplayItem] = SampleData.taskDisplayItems
    @State private var selectedPriority: String? = nil

    private var pendingTasks: [TaskDisplayItem] {
        let pending = taskDisplayItems.filter { $0.status != "Completed" }
        if let priority = selectedPriority {
            return pending.filter { $0.priority == priority }
        }
        return pending
    }

    private var completedTasks: [TaskDisplayItem] {
        let completed = taskDisplayItems.filter { $0.status == "Completed" }
        if let priority = selectedPriority {
            return completed.filter { $0.priority == priority }
        }
        return completed
    }

    private func countByPriority(_ priority: String) -> Int {
        taskDisplayItems.filter { $0.priority == priority }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: - Header
                HStack {
                    Text("Clinical Tasks")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    HStack(spacing: 8) {
                        PriorityFilterButton(
                            label: "High Priority",
                            count: countByPriority("High"),
                            color: .red,
                            isSelected: selectedPriority == "High"
                        ) {
                            selectedPriority = selectedPriority == "High" ? nil : "High"
                        }

                        PriorityFilterButton(
                            label: "Medium",
                            count: countByPriority("Medium"),
                            color: .yellow,
                            isSelected: selectedPriority == "Medium"
                        ) {
                            selectedPriority = selectedPriority == "Medium" ? nil : "Medium"
                        }

                        PriorityFilterButton(
                            label: "Low",
                            count: countByPriority("Low"),
                            color: .blue,
                            isSelected: selectedPriority == "Low"
                        ) {
                            selectedPriority = selectedPriority == "Low" ? nil : "Low"
                        }
                    }
                }

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
                                PendingTaskRow(task: task)
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
                                CompletedTaskRow(task: task)
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
    }
}

// MARK: - Priority Filter Button

struct PriorityFilterButton: View {
    let label: String
    let count: Int
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(label) (\(count))")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(isSelected ? .white : color)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSelected ? color : color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}

// MARK: - Pending Task Row

struct PendingTaskRow: View {
    let task: TaskDisplayItem

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Left side: task info
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(task.patientName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let dueDate = task.dueDate {
                    Text("Due: \(dueDate)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
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

                Button(action: {}) {
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
    let task: TaskDisplayItem

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.body)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .strikethrough(true, color: .secondary)

                Text(task.patientName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let completedDate = task.completedDate {
                    Text("Completed on \(completedDate)")
                        .font(.caption2)
                        .foregroundStyle(.green)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    TasksView()
}
