# AppointmentManager

AppointmentManager is a full-stack healthcare workflow tool — **ClinicalFlow** — that helps clinical staff manage patients, appointments, and tasks. It consists of a .NET REST API backend and a native iOS app.

---

## Repository Structure

```
AppointmentManager/
├── backend/      # ASP.NET Core Web API + PostgreSQL
└── mobile/       # iOS SwiftUI app (ClinicalFlow)
```

---

## Backend

**Location:** `backend/AppointmentScheduler/`

An ASP.NET Core Web API backed by PostgreSQL. All endpoints require JWT authentication except registration and login.

### Stack
- .NET (ASP.NET Core)
- PostgreSQL via Npgsql
- JWT Bearer authentication
- Swagger / OpenAPI (available in development)
- Docker Compose for local database

### Running Locally

1. Start the database:
   ```bash
   cd backend/AppointmentScheduler
   docker compose up -d
   ```
2. Run the API:
   ```bash
   dotnet run
   ```
3. Swagger UI is available at `http://localhost:<port>/swagger` in development.

### API Endpoints

| Controller | Method | Route | Description |
|---|---|---|---|
| Auth | POST | `/auth/register` | Register a new user |
| Auth | POST | `/auth/login` | Login and receive a JWT |
| Patient | GET | `/patient` | List all patients |
| Patient | GET | `/patient/{id}` | Get a patient by ID |
| Patient | POST | `/patient` | Create a patient |
| Patient | PUT | `/patient/{id}` | Update a patient |
| Appointment | GET | `/appointment` | List all appointments |
| Appointment | GET | `/appointment/{patient_id}` | Get appointments for a patient |
| Appointment | POST | `/appointment` | Create an appointment |
| Appointment | PUT | `/appointment/{id}` | Update an appointment |
| Appointment | DELETE | `/appointment/{id}` | Delete an appointment |
| TaskItem | GET | `/taskitem` | List all tasks |
| TaskItem | POST | `/taskitem` | Create a task |
| TaskItem | PUT | `/taskitem/{id}` | Update a task |
| TaskItem | DELETE | `/taskitem/{id}` | Delete a task |

### Testing

```bash
cd backend
dotnet test
```

---

## iOS App (ClinicalFlow)

**Location:** `mobile/AppointmentManagerIOS/`

A native iPhone and iPad app built with SwiftUI that connects to the backend API.

### Stack
- Swift 6, iOS 26+
- SwiftUI with MVVM architecture (`@Observable` ViewModels)
- SwiftData for persistent local storage
- Async/await for all networking

### Features
- **Login / Sign Up** — authenticates against the backend, stores the JWT locally
- **Dashboard** — summary overview with quick navigation
- **Patients** — browse, add, and edit patient records
- **Appointments** — view and manage appointments, filterable by patient
- **Tasks** — create and track workflow task items

### Project Structure
```
AppointmentManagerIOS/
├── Views/          # SwiftUI views (Dashboard, Patients, Appointments, Tasks, Login, SignUp)
├── ViewModels/     # Observable ViewModels for each feature
├── Models/         # Codable data models (Patient, Appointment, TaskItem, User, ...)
└── Services/       # APIService (HTTP client), DataStore (local cache)
```

### Building

Open `mobile/AppointmentManagerIOS/AppointmentManagerIOS.xcodeproj` in Xcode and run on a simulator or device.
