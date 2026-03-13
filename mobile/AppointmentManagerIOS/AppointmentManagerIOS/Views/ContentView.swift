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

    var body: some View {
        Text("This is a blank view")
    }
}

#Preview {
    ContentView()
}
