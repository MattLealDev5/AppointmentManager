using AppointmentScheduler.Models;
using AppointmentScheduler.Repositories;
using Microsoft.AspNetCore.Mvc;
using Npgsql;
using System.Threading.Tasks;
using Task = AppointmentScheduler.Models.Task;

namespace AppointmentScheduler.Controllers {

    [ApiController]
    [Route("[controller]")]
    public class TaskController : ControllerBase {
        private readonly DatabaseManager _dbManager;

        public TaskController(DatabaseManager dbManager) {
            _dbManager = dbManager;
        }

        [HttpGet]
        public async Task<IActionResult> GetTasks() {
            var tasks = await _dbManager.ExecuteReaderAsync(
                "SELECT id, appointment_id, status, priority FROM tasks;",
                reader => new Task {
                    Id = reader.GetGuid(0),
                    Appointment_id = reader.GetGuid(1),
                    Status = reader.GetString(2),
                    Priority = reader.GetString(3)
                });

            return Ok(tasks);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> EditTask(string id, [FromBody] Task task) {
            Guid checkedID;
            try {
                checkedID = new Guid(id);
            } catch {
                return BadRequest("Invalid id");
            }

            if (task.Status == null) { return BadRequest("Must include status"); }
            if (task.Priority == null) { return BadRequest("Must include priority"); }

            var rowsAffected = await _dbManager.ExecuteNonQueryAsync(
                "UPDATE tasks SET appointment_id = @appointment_id, status = @status, priority = @priority WHERE id = @id;",
                new NpgsqlParameter("@id", checkedID),
                new NpgsqlParameter("@appointment_id", task.Appointment_id),
                new NpgsqlParameter("@status", task.Status),
                new NpgsqlParameter("@priority", task.Priority));

            if (rowsAffected == 0) {
                return NotFound("Task was not found");
            }
            return Ok(task);
        }

        [HttpPut("markOverdue/{id}")]
        public async Task<IActionResult> MarkOverdueTask(string id) {
            Guid checkedID;
            try {
                checkedID = new Guid(id);
            } catch {
                return BadRequest("Invalid id");
            }

            var rowsAffected = await _dbManager.ExecuteNonQueryAsync(
                "UPDATE tasks SET status = @status WHERE id = @id;",
                new NpgsqlParameter("@id", checkedID),
                new NpgsqlParameter("@status", "Overdue"));

            if (rowsAffected == 0) {
                return NotFound("Task was not found");
            }
            return Ok();
        }
    }
}
