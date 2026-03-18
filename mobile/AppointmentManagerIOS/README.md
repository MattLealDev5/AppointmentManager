# iOS App (ClinicalFlow)

A native iPhone and iPad app built with SwiftUI that connects to the backend API.

## Stack
- Swift 6, iOS 26+
- SwiftUI with MVVM architecture (`@Observable` ViewModels)
- SwiftData for persistent local storage
- Async/await for all networking

## Features
- **Login / Sign Up** — authenticates against the backend, stores the JWT locally
- **Dashboard** — summary overview with quick navigation
- **Patients** — browse, add, and edit patient records
- **Appointments** — view and manage appointments, filterable by patient
- **Tasks** — create and track workflow task items

## Project Structure
```
AppointmentManagerIOS/
├── Views/          # SwiftUI views (Dashboard, Patients, Appointments, Tasks, Login, SignUp)
├── ViewModels/     # Observable ViewModels for each feature
├── Models/         # Codable data models (Patient, Appointment, TaskItem, User, ...)
└── Services/       # APIService (HTTP client), DataStore (local cache)
```

## Building

Open `AppointmentManagerIOS.xcodeproj` in Xcode and run on a simulator or device.
