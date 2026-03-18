//
//  DashboardView.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 3/12/26.
//

import SwiftUI

struct DashboardView: View {
    var dataStore: DataStore = DataStore()
    @Binding var selectedTab: Int

    private var pendingTasks: Int { dataStore.pendingTaskItems.count }
    private var todayAppointments: Int { dataStore.todayAppointments.count }
    private var activePatients: Int { dataStore.activePatientsCount }
    private var overdueItems: Int { dataStore.overdueTaskItems.count }
    private var scheduleItems: [ScheduleItem] { dataStore.todayScheduleItems }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                    // MARK: - Stat Cards
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(
                            title: "Pending Tasks",
                            value: "\(pendingTasks)",
                            icon: "doc.text",
                            accentColor: .blue
                        )
                        StatCard(
                            title: "Today's Appointments",
                            value: "\(todayAppointments)",
                            icon: "calendar",
                            accentColor: .green
                        )
                        StatCard(
                            title: "Active Patients",
                            value: "\(activePatients)",
                            icon: "person.2",
                            accentColor: .purple
                        )
                        StatCard(
                            title: "Overdue Items",
                            value: "\(overdueItems)",
                            icon: "clock",
                            accentColor: .red
                        )
                    }

                    // MARK: - Today's Schedule
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundStyle(.secondary)
                            Text("Today's Schedule")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Spacer()
                            Button("View All") { selectedTab = 2 }
                                .font(.subheadline)
                        }

                        VStack(spacing: 0) {
                            ForEach(Array(scheduleItems.enumerated()), id: \.element.id) { index, item in
                                ScheduleRow(item: item)
                                if index < scheduleItems.count - 1 {
                                    Divider()
                                        .padding(.leading, 72)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Colored top bar
            accentColor
                .frame(height: 4)
                .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(accentColor)
                    Spacer()
                    Text(value)
                        .font(.title)
                        .fontWeight(.bold)
                }

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Schedule Row

struct ScheduleRow: View {
    let item: ScheduleItem

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Time column
            VStack(spacing: 0) {
                Text(item.time)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(item.period)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 50)

            // Vertical accent line
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.blue)
                .frame(width: 3, height: 36)

            // Details
            VStack(alignment: .leading, spacing: 2) {
                Text(item.patientName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(item.reason)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Status badge
            Text(item.status.rawValue)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(item.status.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(item.status.color.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
    }
}

#Preview {
    DashboardView(selectedTab: .constant(0))
}
