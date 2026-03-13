//
//  DashboardView.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 3/12/26.
//

import SwiftUI

struct DashboardView: View {
    var pendingTasks: Int = SampleData.pendingTaskCount
    var todayAppointments: Int = SampleData.todayAppointmentCount
    var activePatients: Int = SampleData.activePatientCount
    var overdueItems: Int = SampleData.overdueTaskCount
    var scheduleItems: [ScheduleItem] = SampleData.scheduleItems

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                    // MARK: - Stat Cards
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(
                            title: "Pending Tasks",
                            value: "\(pendingTasks)",
                            subtitle: "+3 from yesterday",
                            icon: "doc.text",
                            accentColor: .blue
                        )
                        StatCard(
                            title: "Today's Appointments",
                            value: "\(todayAppointments)",
                            subtitle: "2 completed",
                            icon: "calendar",
                            accentColor: .green
                        )
                        StatCard(
                            title: "Active Patients",
                            value: "\(activePatients)",
                            subtitle: "+5 this week",
                            icon: "person.2",
                            accentColor: .purple
                        )
                        StatCard(
                            title: "Overdue Items",
                            value: "\(overdueItems)",
                            subtitle: "Needs attention",
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
                            Button("View All") {}
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
    let subtitle: String
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

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
    DashboardView()
}
