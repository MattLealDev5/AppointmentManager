//
//  LoginRequest.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 2/27/26.
//


import Foundation
import SwiftData

@Model
final class LoginRequest: Codable {
    var username: String
    var password: String
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    // MARK: - Codable conformance for API requests

    enum CodingKeys: String, CodingKey {
        case username
        case password
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.username = try container.decode(String.self, forKey: .username)
        self.password = try container.decode(String.self, forKey: .password)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(username, forKey: .username)
        try container.encode(password, forKey: .password)
    }
}
