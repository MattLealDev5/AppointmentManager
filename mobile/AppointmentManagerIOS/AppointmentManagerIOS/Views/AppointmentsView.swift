//
//  AppointmentsView.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 3/16/26.
//

import SwiftUI

struct AppointmentsView: View {
    var appointments: [Appointment] = SampleData.appointments
    @State private var displayedMonth = Date()
    @State private var selectedDate: Date?
    @State private var selectedAppointments: [Appointment] = []
    @State private var showingSheet = false

    private let calendar = Calendar.current
    private let weekdaySymbols = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: - Header
                HStack {
                    Text("Appointments")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    Button(action: {}) {
                        Label("Schedule Appointment", systemImage: "plus")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }

                // MARK: - Calendar Card
                VStack(spacing: 0) {
                    // Month navigation
                    HStack {
                        Button(action: { changeMonth(by: -1) }) {
                            Image(systemName: "chevron.left")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                                .frame(width: 36, height: 36)
                                .background(Color(.tertiarySystemFill))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        Spacer()

                        Text(monthYearString)
                            .font(.headline)
                            .fontWeight(.bold)

                        Spacer()

                        Button(action: { changeMonth(by: 1) }) {
                            Image(systemName: "chevron.right")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                                .frame(width: 36, height: 36)
                                .background(Color(.tertiarySystemFill))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(16)

                    Divider()

                    // Weekday headers
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 0) {
                        ForEach(weekdaySymbols, id: \.self) { day in
                            Text(day)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                    }
                    .padding(.horizontal, 8)

                    Divider()

                    // Calendar grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                        ForEach(calendarDays, id: \.self) { date in
                            if let date = date {
                                let dayAppointments = appointmentsFor(date: date)
                                CalendarDayCell(
                                    day: calendar.component(.day, from: date),
                                    isToday: calendar.isDateInToday(date),
                                    hasAppointments: !dayAppointments.isEmpty,
                                    appointmentCount: dayAppointments.count
                                )
                                .onTapGesture {
                                    selectedDate = date
                                    selectedAppointments = dayAppointments
                                    showingSheet = true
                                }
                            } else {
                                Color.clear
                                    .frame(height: 44)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingSheet) {
            AppointmentDaySheet(
                date: selectedDate ?? Date(),
                appointments: selectedAppointments
            )
            .presentationDetents([.medium, .large])
        }
    }

    // MARK: - Helpers

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newDate
        }
    }

    private var calendarDays: [Date?] {
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstOfMonth) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let leadingBlanks = firstWeekday - 1

        var days: [Date?] = Array(repeating: nil, count: leadingBlanks)

        for day in range {
            var dayComponents = components
            dayComponents.day = day
            days.append(calendar.date(from: dayComponents))
        }

        return days
    }

    private func appointmentsFor(date: Date) -> [Appointment] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        return appointments.filter { appointment in
            guard let appointmentDate = appointment.date else { return false }
            return appointmentDate.hasPrefix(dateString)
        }
    }
}

// MARK: - Calendar Day Cell

struct CalendarDayCell: View {
    let day: Int
    let isToday: Bool
    let hasAppointments: Bool
    let appointmentCount: Int

    var body: some View {
        VStack(spacing: 4) {
            Text("\(day)")
                .font(.body)
                .fontWeight(isToday || hasAppointments ? .bold : .regular)
                .foregroundStyle(hasAppointments || isToday ? .white : .primary)
                .frame(width: 38, height: 38)
                .background(
                    Circle()
                        .fill(circleColor)
                )

            // Small dot indicator for appointment count
            if hasAppointments {
                Text("\(appointmentCount)")
                    .font(.system(size: 10))
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
            } else {
                // Keep spacing consistent
                Text(" ")
                    .font(.system(size: 10))
            }
        }
        .frame(height: 56)
        .contentShape(Rectangle())
    }

    private var circleColor: Color {
        if hasAppointments {
            return .blue
        } else if isToday {
            return .gray.opacity(0.3)
        } else {
            return .clear
        }
    }
}

// MARK: - Appointment Day Sheet

struct AppointmentDaySheet: View {
    let date: Date
    let appointments: [Appointment]

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: date)
    }

    var body: some View {
        NavigationStack {
            Group {
                if appointments.isEmpty {
                    ContentUnavailableView(
                        "No Appointments",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("There are no appointments scheduled for this day.")
                    )
                } else {
                    List(appointments) { appointment in
                        HStack(spacing: 14) {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 10, height: 10)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(appointment.type ?? "Appointment")
                                    .font(.body)
                                    .fontWeight(.semibold)

                                if let dateStr = appointment.date {
                                    Text(formattedTime(from: dateStr))
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(dateString)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func formattedTime(from dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let date = inputFormatter.date(from: dateString) else { return dateString }
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mm a"
        return outputFormatter.string(from: date)
    }
}

#Preview {
    AppointmentsView()
}
