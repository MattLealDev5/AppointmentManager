//
//  Patient.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 3/11/26.
//

import Foundation

struct Patient: Codable, Identifiable {
    var id: UUID?
    var name: String
    var date_of_birth: String
    var email: String
}
