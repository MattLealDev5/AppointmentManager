//
//  ContentView.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 2/27/26.
//

import SwiftUI

struct ContentView: View {
    @State private var authVM = AuthViewModel()
    @State private var patientVM = PatientViewModel()

    // Temp register values
    @State private var regUsername = "Danny"
    @State private var regPassword = "KylePassword"
    @State private var regRole = "FrontDesk"
    @State private var regEmail = "kyle@email.com"
    @State private var regPhone = "666-666-6666"

    // Temp login values
    @State private var loginUsername = "Danny"
    @State private var loginPassword = "KylePassword"

    // Temp patient values
    @State private var patientName = "John Doe"
    @State private var patientDOB = "1990-01-15"
    @State private var patientEmail = "john@email.com"

    // Temp patient ID for get/update by ID
    @State private var patientId = "d64b6b1e-f012-4d32-b4c7-ecbde843c7bd"

    // Temp update patient values
    @State private var updateName = "John Updated"
    @State private var updateDOB = "1990-01-15"
    @State private var updateEmail = "john.updated@email.com"

    var body: some View {
        VStack(spacing: 30) {
            VStack {
                Text("Register User")
                Button("Register") {
                    Task {
                        await authVM.register(
                            username: regUsername,
                            password: regPassword,
                            role: regRole,
                            email: regEmail,
                            phone: regPhone
                        )
                    }
                }
            }

            VStack {
                Text("Login User")
                Button("Login") {
                    Task {
                        await authVM.login(
                            username: loginUsername,
                            password: loginPassword
                        )
                    }
                }
            }

            VStack {
                Text("Make Patient")
                Button("Create") {
                    Task {
                        await patientVM.createPatient(
                            name: patientName,
                            dateOfBirth: patientDOB,
                            email: patientEmail,
                            token: authVM.token
                        )
                    }
                }
            }

            VStack {
                Text("Get Patients")
                Button("Fetch") {
                    Task { await patientVM.fetchPatients(token: authVM.token) }
                }
            }

            VStack {
                Text("Get Patient by ID")
                Button("Fetch by ID") {
                    Task {
                        await patientVM.fetchPatient(id: patientId, token: authVM.token)
                    }
                }
            }

            VStack {
                Text("Update Patient")
                Button("Update") {
                    Task {
                        await patientVM.updatePatient(
                            id: patientId,
                            name: updateName,
                            dateOfBirth: updateDOB,
                            email: updateEmail,
                            token: authVM.token
                        )
                    }
                }
            }

            Text(authVM.statusMessage)
                .foregroundStyle(authVM.isLoggedIn ? .green : .red)
                .font(.caption)

            Text(patientVM.statusMessage)
                .font(.caption)
        }
    }
}

#Preview {
    ContentView()
}
