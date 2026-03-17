//
//  PatientsView.swift
//  AppointmentManagerIOS
//
//  Created by Matthew Leal on 3/16/26.
//

import SwiftUI

struct PatientsView: View {
    var patients: [Patient] = SampleData.patients
    @State private var searchText = ""

    private var filteredPatients: [Patient] {
        if searchText.isEmpty {
            return patients
        }
        return patients.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: - Header
                HStack {
                    Text("Patient Management")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    Button(action: {}) {
                        Label("New Patient", systemImage: "plus")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }

                // MARK: - Patient List Card
                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Search patients by name...", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(12)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(16)

                    Divider()

                    // Column headers
                    HStack {
                        Text("PATIENT NAME")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("DATE OF BIRTH")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("EMAIL")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)

                    Divider()

                    // Patient rows
                    if filteredPatients.isEmpty {
                        Text("No patients found")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                    } else {
                        ForEach(filteredPatients) { patient in
                            PatientRow(patient: patient)
                            if patient.id != filteredPatients.last?.id {
                                Divider()
                                    .padding(.leading, 16)
                            }
                        }
                    }
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Patient Row

struct PatientRow: View {
    let patient: Patient

    var body: some View {
        HStack {
            // Patient name with icon
            HStack(spacing: 10) {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 32, height: 32)
                    .overlay {
                        Text(initials(from: patient.name))
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                    }
                Text(patient.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Date of birth
            Text(formattedDate(patient.date_of_birth))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Email
            Text(patient.email)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        return parts.prefix(2).compactMap { $0.first }.map { String($0) }.joined()
    }

    private func formattedDate(_ dateString: String) -> String {
        // Converts "1985-03-12" to "Mar 12, 1985"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return dateString }
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    PatientsView()
}
