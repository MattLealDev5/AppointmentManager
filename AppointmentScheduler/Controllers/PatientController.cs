using AppointmentScheduler.Models;
using AppointmentScheduler.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Npgsql;
using System.Text.RegularExpressions;
using static System.Reflection.Metadata.BlobBuilder;

namespace AppointmentScheduler.Controllers {

    [ApiController]
    [Route("[controller]")]
    public class PatientController : ControllerBase {
        private readonly DatabaseManager _dbManager;

        public PatientController(DatabaseManager dbManager) {
            _dbManager = dbManager;
        }

        [HttpGet]
        [Authorize]
        public async Task<IActionResult> GetPatients() {
            var patients = await _dbManager.ExecuteReaderAsync(
                "SELECT id, name, date_of_birth, email FROM patient;",
                reader => new Patient {
                    Id = reader.GetGuid(0),
                    Name = reader.GetString(1),
                    Date_of_birth = reader.GetDateTime(2),
                    Email = reader.GetString(3)
                });

            return Ok(patients);
        }

        [HttpGet("{id}")]
        [Authorize]
        public async Task<IActionResult> GetPatientID(string id) {
            Guid checkedID;
            try {
                checkedID = new Guid(id);
            } catch {
                return BadRequest("Invalid id");
            }

            var patient = await _dbManager.ExecuteReaderAsync(
                "SELECT id, name, date_of_birth, email FROM patient WHERE patient.id = @id;",
                reader => new Patient {
                    Id = reader.GetGuid(0),
                    Name = reader.GetString(1),
                    Date_of_birth = reader.GetDateTime(2),
                    Email = reader.GetString(3)
                },
                new NpgsqlParameter("@id", checkedID));

            return Ok(patient);
        }

        bool IsValidEmail(string email) {
            if (string.IsNullOrWhiteSpace(email))
                return false;

            // Balanced regex pattern
            string pattern = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";

            return Regex.IsMatch(email, pattern, RegexOptions.IgnoreCase);
        }
        [HttpPost]
        [Authorize]
        public async Task<IActionResult> CreatePatient([FromBody] Patient patient) {
            if (patient.Name == null) { return BadRequest("Must include name"); }
            if (patient.Date_of_birth == null) { return BadRequest("Must include date of birth"); }
            if (patient.Email == null) { return BadRequest("Must include email"); }
            if (!IsValidEmail(patient.Email)) { return BadRequest("Not a valid email"); }

            patient.Id = Guid.NewGuid();

            await _dbManager.ExecuteNonQueryAsync(
                "INSERT INTO patient (id, name, date_of_birth, email) VALUES (@id, @name, @date_of_birth, @email);",
                new NpgsqlParameter("@id", patient.Id),
                new NpgsqlParameter("@name", patient.Name),
                new NpgsqlParameter("@date_of_birth", patient.Date_of_birth),
                new NpgsqlParameter("@email", patient.Email));

            return CreatedAtAction(nameof(GetPatients), new { id = patient.Id }, patient);
        }

        [HttpPut("{id}")]
        [Authorize]
        public async Task<IActionResult> EditPatient(string id, [FromBody] Patient patient) {
            Guid checkedID;
            try {
                checkedID = new Guid(id);
            } catch {
                return BadRequest("Invalid id");
            }

            if (patient.Name == null) { return BadRequest("Must include name"); }
            if (patient.Date_of_birth == null) { return BadRequest("Must include date of birth"); }
            if (patient.Email == null) { return BadRequest("Must include email"); }
            if (!IsValidEmail(patient.Email)) { return BadRequest("Not a valid email"); }

            var rowsAffected = await _dbManager.ExecuteNonQueryAsync(
                "UPDATE patient SET name = @name, date_of_birth = @date_of_birth, email = @email WHERE id = @id;",
                new NpgsqlParameter("@id", checkedID),
                new NpgsqlParameter("@name", patient.Name),
                new NpgsqlParameter("@date_of_birth", patient.Date_of_birth),
                new NpgsqlParameter("@email", patient.Email));

            if (rowsAffected == 0) {
                return NotFound("Patient was not found");
            }
            return Ok(patient);
        }
    }
}
