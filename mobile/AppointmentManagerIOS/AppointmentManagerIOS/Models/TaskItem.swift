//
//  TaskItem.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 3/11/26.
//

import Foundation

struct TaskItem: Codable, Identifiable {
    var id: String?
    var appointment_id: UUID
    var status: String
    var priority: String
}
