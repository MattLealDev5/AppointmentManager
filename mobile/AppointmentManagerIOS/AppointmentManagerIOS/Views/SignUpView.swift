//
//  SignUpView.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 3/16/26.
//

import SwiftUI
import SwiftData

struct SignUpView: View {
    @Bindable var authVM: AuthViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var role = ""
    @State private var email = ""
    @State private var phone = ""

    private var passwordsMatch: Bool {
        !password.isEmpty && password == confirmPassword
    }

    private var formIsValid: Bool {
        !username.isEmpty && passwordsMatch && !role.isEmpty && !email.isEmpty && !phone.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Branding
                VStack(spacing: 4) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 48))
                        .foregroundStyle(.blue)
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Join ClinicalFlow")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)

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
                        .textContentType(.oneTimeCode)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    SecureField("Confirm Password", text: $confirmPassword)
                        .textContentType(.oneTimeCode)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    if !confirmPassword.isEmpty && !passwordsMatch {
                        Text("Passwords do not match")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    TextField("Role (e.g. Doctor, Nurse)", text: $role)
                        .textInputAutocapitalization(.words)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    TextField("Phone", text: $phone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
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

                // Sign Up button
                Button(action: {
                    Task {
                        await authVM.register(
                            username: username,
                            password: password,
                            role: role,
                            email: email,
                            phone: phone,
                            modelContext: modelContext
                        )
                    }
                }) {
                    if authVM.isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Sign Up")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                .disabled(!formIsValid || authVM.isLoading)

                // Back to login
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .foregroundStyle(.secondary)
                        Text("Log In")
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                    }
                    .font(.subheadline)
                }
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    NavigationStack {
        SignUpView(authVM: AuthViewModel())
    }
    .modelContainer(for: LoginRequest.self, inMemory: true)
}
