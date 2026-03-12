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
    @State private var appointmentVM = AppointmentViewModel()
    @State private var taskItemVM = TaskItemViewModel()

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
    @State private var patientId = "1392072f-42b7-462b-b90f-17015c4436a2"

    // Temp update patient values
    @State private var updateName = "John Updated"
    @State private var updateDOB = "1990-01-15"
    @State private var updateEmail = "john.updated@email.com"

    // Temp appointment values
    @State private var apptDate = "2026-04-15"
    @State private var apptType = "Checkup"
    @State private var apptId = "3572c58f-9b7c-458d-9709-bd210b722507"

    // Temp update appointment values
    @State private var updateApptDate = "2026-05-01"
    @State private var updateApptType = "Follow-up"

    // Temp task item values
    @State private var taskItemId = "b414f279-f10e-40d6-9873-24a33332a9b7"
    @State private var taskItemStatus = "Pending"
    @State private var taskItemPriority = "High"
    @State private var taskItemFilterStatus = "pending"

    // Temp update task item values
    @State private var updateTaskStatus = "InProgress"
    @State private var updateTaskPriority = "Medium"

    var body: some View {
        VStack(spacing: 30) {
//            VStack {
//                Text("Register User")
//                Button("Register") {
//                    Task {
//                        await authVM.register(
//                            username: regUsername,
//                            password: regPassword,
//                            role: regRole,
//                            email: regEmail,
//                            phone: regPhone
//                        )
//                    }
//                }
//            }

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

//            VStack {
//                Text("Make Patient")
//                Button("Create") {
//                    Task {
//                        await patientVM.createPatient(
//                            name: patientName,
//                            dateOfBirth: patientDOB,
//                            email: patientEmail,
//                            token: authVM.token
//                        )
//                    }
//                }
//            }

            VStack {
                Text("Get Patients")
                Button("Fetch") {
                    Task { await patientVM.fetchPatients(token: authVM.token) }
                }
            }

//            VStack {
//                Text("Get Patient by ID")
//                Button("Fetch by ID") {
//                    Task {
//                        await patientVM.fetchPatient(id: patientId, token: authVM.token)
//                    }
//                }
//            }
//
//            VStack {
//                Text("Update Patient")
//                Button("Update") {
//                    Task {
//                        await patientVM.updatePatient(
//                            id: patientId,
//                            name: updateName,
//                            dateOfBirth: updateDOB,
//                            email: updateEmail,
//                            token: authVM.token
//                        )
//                    }
//                }
//            }

//            VStack {
//                Text("Get All Appointments")
//                Button("Fetch All") {
//                    Task { await appointmentVM.fetchAppointments(token: authVM.token) }
//                }
//            }

            VStack {
                Text("Create Appointment")
                Button("Create") {
                    Task {
                        await appointmentVM.createAppointment(
                            patientId: patientId,
                            date: apptDate,
                            type: apptType,
                            token: authVM.token
                        )
                    }
                }
            }

            VStack {
                Text("Get Appointments by Patient")
                Button("Fetch by Patient") {
                    Task {
                        await appointmentVM.fetchAppointments(
                            patientId: patientId,
                            token: authVM.token
                        )
                    }
                }
            }

//            VStack {
//                Text("Update Appointment")
//                Button("Update") {
//                    Task {
//                        await appointmentVM.updateAppointment(
//                            id: apptId,
//                            patientId: patientId,
//                            date: updateApptDate,
//                            type: updateApptType,
//                            token: authVM.token
//                        )
//                    }
//                }
//            }

            VStack {
                Text("Delete Appointment")
                Button("Delete") {
                    Task {
                        await appointmentVM.deleteAppointment(
                            id: apptId,
                            token: authVM.token
                        )
                    }
                }
            }

            VStack {
                Text("Get All Task Items")
                Button("Fetch All") {
                    Task { await taskItemVM.fetchTaskItems(token: authVM.token) }
                }
            }

            VStack {
                Text("Get Task Items by Status")
                Button("Fetch by Status") {
                    Task {
                        await taskItemVM.fetchTaskItems(
                            status: taskItemFilterStatus,
                            token: authVM.token
                        )
                    }
                }
            }

            VStack {
                Text("Update Task Item")
                Button("Update") {
                    Task {
                        await taskItemVM.updateTaskItem(
                            id: taskItemId,
                            appointmentId: apptId,
                            status: updateTaskStatus,
                            priority: updateTaskPriority,
                            token: authVM.token
                        )
                    }
                }
            }

            VStack {
                Text("Mark Task Item Overdue")
                Button("Mark Overdue") {
                    Task {
                        await taskItemVM.markTaskItemOverdue(
                            id: taskItemId,
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

            Text(appointmentVM.statusMessage)
                .font(.caption)

            Text(taskItemVM.statusMessage)
                .font(.caption)
        }
    }
}

#Preview {
    ContentView()
}
