//
//  LoginRequest.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 2/27/26.
//


import Foundation
import SwiftData

@Model
final class LoginRequest {
    var username: String
    var password: String
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}
