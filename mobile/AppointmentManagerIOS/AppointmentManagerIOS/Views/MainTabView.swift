//
//  MainTabView.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 3/12/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    var user: UserProfile = SampleData.currentUser

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Toolbar
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text("ClinicalFlow")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Workflow Task Manager")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 16) {
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .font(.body)
                            .foregroundStyle(.primary)
                    }

                    HStack(spacing: 8) {
                        VStack(alignment: .trailing, spacing: 0) {
                            Text(user.name)
                                .font(.caption)
                                .fontWeight(.medium)
                            Text(user.role)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Circle()
                            .fill(Color(.tertiarySystemFill))
                            .frame(width: 32, height: 32)
                            .overlay {
                                Text(initials(from: user.name))
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                            }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))

            // MARK: - Tab Content
            TabView(selection: $selectedTab) {
                Tab("Dashboard", systemImage: "house", value: 0) {
                    DashboardView()
                }

                Tab("Patients", systemImage: "person.2", value: 1) {
                    PatientsView()
                }

                Tab("Appointments", systemImage: "calendar", value: 2) {
                    AppointmentsView()
                }

                Tab("Tasks", systemImage: "checklist", value: 3) {
                    TasksView()
                }
            }
        }
    }

    private func initials(from name: String) -> String {
        let parts = name.replacingOccurrences(of: "Dr. ", with: "").split(separator: " ")
        let result = parts.prefix(2).compactMap { $0.first }.map { String($0) }.joined()
        return result
    }
}

#Preview {
    MainTabView()
}
