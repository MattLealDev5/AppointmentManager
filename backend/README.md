# Backend

An ASP.NET Core Web API backed by PostgreSQL. All endpoints require JWT authentication except registration and login.

## Stack
- .NET (ASP.NET Core)
- PostgreSQL via Npgsql
- JWT Bearer authentication
- Swagger / OpenAPI (available in development)
- Docker Compose for local database

## Running Locally

1. Start the database:
   ```bash
   cd AppointmentScheduler
   docker compose up -d
   ```
2. Run the API:
   ```bash
   dotnet run
   ```
3. Swagger UI is available at `http://localhost:<port>/swagger` in development.

## API Endpoints

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

## Testing

```bash
dotnet test
```
