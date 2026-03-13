//
//  SampleData.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 3/12/26.
//

import Foundation
import SwiftUI

enum SampleData {
    static let patients: [Patient] = [
        Patient(id: UUID(), name: "Sarah Johnson", date_of_birth: "1985-03-12", email: "sarah@email.com"),
        Patient(id: UUID(), name: "Michael Chen", date_of_birth: "1972-07-25", email: "michael@email.com"),
        Patient(id: UUID(), name: "Emily Rodriguez", date_of_birth: "1990-11-08", email: "emily@email.com"),
        Patient(id: UUID(), name: "James Wilson", date_of_birth: "1968-01-30", email: "james@email.com"),
    ]

    static let appointments: [Appointment] = [
        Appointment(id: "1", patient_id: "p1", date: "2026-03-12T09:00:00", type: "Follow-up"),
        Appointment(id: "2", patient_id: "p2", date: "2026-03-12T10:30:00", type: "Annual Physical"),
        Appointment(id: "3", patient_id: "p3", date: "2026-03-12T14:00:00", type: "New Patient"),
    ]

    static let taskItems: [TaskItem] = [
        TaskItem(id: "t1", appointment_id: UUID(), status: "Pending", priority: "High"),
        TaskItem(id: "t2", appointment_id: UUID(), status: "Pending", priority: "Medium"),
        TaskItem(id: "t3", appointment_id: UUID(), status: "InProgress", priority: "High"),
        TaskItem(id: "t4", appointment_id: UUID(), status: "Overdue", priority: "High"),
        TaskItem(id: "t5", appointment_id: UUID(), status: "Pending", priority: "Low"),
    ]

    /// Schedule items combine appointment + patient info for display
    static let scheduleItems: [ScheduleItem] = [
        ScheduleItem(time: "09:00", period: "AM", patientName: "Sarah Johnson", reason: "Follow-up · Dr. Smith", status: .scheduled),
        ScheduleItem(time: "10:30", period: "AM", patientName: "Michael Chen", reason: "Annual Physical · Dr. Johnson", status: .scheduled),
        ScheduleItem(time: "02:00", period: "PM", patientName: "Emily Rodriguez", reason: "New Patient · Dr. Smith", status: .scheduled),
    ]

    static let currentUser = UserProfile(name: "Dr. Sarah Smith", role: "Primary Care")

    static var pendingTaskCount: Int {
        taskItems.filter { $0.status == "Pending" }.count
    }

    static var overdueTaskCount: Int {
        taskItems.filter { $0.status == "Overdue" }.count
    }

    static var todayAppointmentCount: Int {
        appointments.count
    }

    static var activePatientCount: Int {
        patients.count
    }
}

/// A display model for schedule rows
struct ScheduleItem: Identifiable {
    let id = UUID()
    let time: String
    let period: String
    let patientName: String
    let reason: String
    let status: AppointmentStatus
}

enum AppointmentStatus: String {
    case scheduled = "Scheduled"
    case completed = "Completed"
    case cancelled = "Cancelled"

    var color: Color {
        switch self {
        case .scheduled: return .blue
        case .completed: return .green
        case .cancelled: return .red
        }
    }
}

/// A display model for the logged-in user
struct UserProfile {
    let name: String
    let role: String
}
