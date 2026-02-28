//
//  Appointment.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 2/27/26.
//

import Foundation
import SwiftData

struct Appointment {
    var id: UUID
    var patient_id: UUID
    var date: Date?
    var type: String?
}
