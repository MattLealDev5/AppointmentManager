//
//  MainTabView.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 3/12/26.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    var authVM: AuthViewModel
    var dataStore: DataStore
    @Environment(\.modelContext) private var modelContext
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
                    // MARK: - Logout Button
                    Button(action: {
                        authVM.logout(modelContext: modelContext)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.caption)
                            Text("Log Out")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // MARK: - User Profile (commented out for future use)
                    // HStack(spacing: 8) {
                    //     VStack(alignment: .trailing, spacing: 0) {
                    //         Text(user.name)
                    //             .font(.caption)
                    //             .fontWeight(.medium)
                    //         Text(user.role)
                    //             .font(.caption2)
                    //             .foregroundStyle(.secondary)
                    //     }
                    //     Circle()
                    //         .fill(Color(.tertiarySystemFill))
                    //         .frame(width: 32, height: 32)
                    //         .overlay {
                    //             Text(initials(from: user.name))
                    //                 .font(.caption2)
                    //                 .fontWeight(.semibold)
                    //                 .foregroundStyle(.secondary)
                    //         }
                    // }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))

            // MARK: - Tab Content
            TabView(selection: $selectedTab) {
                Tab("Dashboard", systemImage: "house", value: 0) {
                    DashboardView(dataStore: dataStore, selectedTab: $selectedTab)
                }

                Tab("Patients", systemImage: "person.2", value: 1) {
                    PatientsView(dataStore: dataStore, authVM: authVM)
                }

                Tab("Appointments", systemImage: "calendar", value: 2) {
                    AppointmentsView(dataStore: dataStore, authVM: authVM)
                }

                Tab("Tasks", systemImage: "checklist", value: 3) {
                    TasksView(dataStore: dataStore, authVM: authVM)
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
    MainTabView(authVM: AuthViewModel(), dataStore: DataStore())
        .modelContainer(for: LoginRequest.self, inMemory: true)
}
