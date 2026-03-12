//
//  Appointment.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 2/27/26.
//

import Foundation

struct Appointment: Codable, Identifiable {
    var id: String?
    var patient_id: String
    var date: String?
    var type: String?
}
