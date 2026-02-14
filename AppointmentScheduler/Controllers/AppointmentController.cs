using AppointmentScheduler.Models;
using AppointmentScheduler.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Npgsql;

namespace AppointmentScheduler.Controllers {

    [ApiController]
    [Route("[controller]")]
    public class AppointmentController : ControllerBase {
        private readonly DatabaseManager _dbManager;

        public AppointmentController(DatabaseManager dbManager) {
            _dbManager = dbManager;
        }

        [HttpGet]
        [Authorize]
        public async Task<IActionResult> GetAppointments() {
            var appointments = await _dbManager.ExecuteReaderAsync(
                "SELECT id, patient_id, date, type FROM appointment;",
                reader => new Appointment {
                    Id = reader.GetGuid(0),
                    Patient_id = reader.GetGuid(1),
                    Date = reader.GetDateTime(2),
                    Type = reader.GetString(3)
                });

            return Ok(appointments);
        }

        [HttpGet("{patient_id}")]
        [Authorize]
        public async Task<IActionResult> GetAppointmentsPID(string patient_id) {
            Guid checkedID;
            try {
                checkedID = new Guid(patient_id);
            } catch {
                return BadRequest("Invalid id");
            }

            var appointment = await _dbManager.ExecuteReaderAsync(
                "SELECT id, patient_id, date, type FROM appointment WHERE appointment.patient_id = @patient_id;",
                reader => new Appointment {
                    Id = reader.GetGuid(0),
                    Patient_id = reader.GetGuid(1),
                    Date = reader.GetDateTime(2),
                    Type = reader.GetString(3)
                },
                new NpgsqlParameter("@patient_id", checkedID));

            return Ok(appointment);
        }

        [HttpPost]
        [Authorize]
        public async Task<IActionResult> CreateAppointment([FromBody] Appointment appointment) {
            if (appointment.Type == null) { return BadRequest("Must include type"); }

            appointment.Id = Guid.NewGuid();

            await _dbManager.ExecuteNonQueryAsync(
                "INSERT INTO appointment (id, patient_id, date, type) VALUES (@id, @patient_id, @date, @type);",
                new NpgsqlParameter("@id", appointment.Id),
                new NpgsqlParameter("@patient_id", appointment.Patient_id),
                new NpgsqlParameter("@date", appointment.Date),
                new NpgsqlParameter("@type", appointment.Type));

            return CreatedAtAction(nameof(CreateAppointment), new { id = appointment.Id }, appointment);
        }

        [HttpPut("{id}")]
        [Authorize]
        public async Task<IActionResult> EditPatient(string id, [FromBody] Appointment appointment) {
            Guid checkedID;
            try {
                checkedID = new Guid(id);
            } catch {
                return BadRequest("Invalid id");
            }

            if (appointment.Type == null) { return BadRequest("Must include reason for visit"); }

            var rowsAffected = await _dbManager.ExecuteNonQueryAsync(
                "UPDATE appointment SET patient_id = @patient_id, date = @date, type = @type WHERE id = @id;",
                new NpgsqlParameter("@id", checkedID),
                new NpgsqlParameter("@patient_id", appointment.Patient_id),
                new NpgsqlParameter("@date", appointment.Date),
                new NpgsqlParameter("@type", appointment.Type));

            if (rowsAffected == 0) {
                return NotFound("Appointment was not found");
            }
            return Ok(appointment);
        }

        [HttpDelete("{id}")]
        [Authorize]
        public async Task<IActionResult> DeleteAppointment(string id) {
            Guid checkedID;
            try {
                checkedID = new Guid(id);
            } catch {
                return BadRequest("Invalid id");
            }

            var rowsAffected = await _dbManager.ExecuteNonQueryAsync(
                "DELETE FROM appointment WHERE id = @id;",
                new NpgsqlParameter("@id", checkedID));

            return NoContent();
        }
    }
}
