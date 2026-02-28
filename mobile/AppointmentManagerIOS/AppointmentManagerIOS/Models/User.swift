//
//  User.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 2/27/26.
//

import Foundation

struct User {
    var id: UUID
    var username: String?
    var passwordHash: String?
    var role: String?
    var email: String?
    var phone: String?
}
