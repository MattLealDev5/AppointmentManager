//
//  RegisterRequest.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 2/27/26.
//

import Foundation

struct RegisterRequest: Codable {
    var username: String
    var password: String
    var role: String
    var email: String
    var phone: String
}
