//
//  User.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 2/27/26.
//

import Foundation
import SwiftData

@Model
final class User {
    var id: UUID
    var username: String?
    var passwordHash: String?
    var role: String?
    var email: String?
    var phone: String?

    init(
        id: UUID = UUID(),
        username: String? = nil,
        passwordHash: String? = nil,
        role: String? = nil,
        email: String? = nil,
        phone: String? = nil
    ) {
        self.id = id
        self.username = username
        self.passwordHash = passwordHash
        self.role = role
        self.email = email
        self.phone = phone
    }
}
