//
//  LoginView.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 3/16/26.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    @Bindable var authVM: AuthViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var username = ""
    @State private var password = ""
    @State private var showSignUp = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Branding
                VStack(spacing: 4) {
                    Image(systemName: "cross.case.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.blue)
                    Text("ClinicalFlow")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Workflow Task Manager")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Fields
                VStack(spacing: 16) {
                    TextField("Username", text: $username)
                        .textContentType(.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal)

                // Status message
                if !authVM.statusMessage.isEmpty && !authVM.isLoggedIn {
                    Text(authVM.statusMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Login button
                Button(action: {
                    Task {
                        await authVM.login(username: username, password: password, modelContext: modelContext)
                    }
                }) {
                    if authVM.isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Log In")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                .disabled(username.isEmpty || password.isEmpty || authVM.isLoading)

                // Sign up link
                Button(action: { showSignUp = true }) {
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .foregroundStyle(.secondary)
                        Text("Sign Up")
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                    }
                    .font(.subheadline)
                }

                Spacer()
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView(authVM: authVM)
            }
        }
    }
}

#Preview {
    LoginView(authVM: AuthViewModel())
        .modelContainer(for: LoginRequest.self, inMemory: true)
}
