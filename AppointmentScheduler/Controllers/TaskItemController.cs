using AppointmentScheduler.Models;
using AppointmentScheduler.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Npgsql;
using System.Threading.Tasks;

namespace AppointmentScheduler.Controllers {

    [ApiController]
    [Route("[controller]")]
    public class TaskItemController : ControllerBase {
        private readonly DatabaseManager _dbManager;

        public TaskItemController(DatabaseManager dbManager) {
            _dbManager = dbManager;
        }

        [HttpGet]
        [Authorize]
        public async Task<IActionResult> GetTasks() {
            var tasks = await _dbManager.ExecuteReaderAsync(
                "SELECT id, appointment_id, status, priority FROM task;",
                reader => new TaskItem {
                    Id = reader.GetGuid(0),
                    Appointment_id = reader.GetGuid(1),
                    Status = reader.GetString(2),
                    Priority = reader.GetString(3)
                });

            return Ok(tasks);
        }

        [HttpGet("{status}")]
        [Authorize]
        public async Task<IActionResult> GetTasks(string status) {
            if (String.IsNullOrEmpty(status)) {
                return BadRequest("Must include a status");
            }

            var tasks = await _dbManager.ExecuteReaderAsync(
                "SELECT id, appointment_id, status, priority FROM task WHERE status LIKE @status;",
                reader => new TaskItem {
                    Id = reader.GetGuid(0),
                    Appointment_id = reader.GetGuid(1),
                    Status = reader.GetString(2),
                    Priority = reader.GetString(3)
                },
                new NpgsqlParameter("@status", status));

            return Ok(tasks);
        }

        [HttpPut("{id}")]
        [Authorize]
        public async Task<IActionResult> EditTask(string id, [FromBody] TaskItem task) {
            Guid checkedID;
            try {
                checkedID = new Guid(id);
            } catch {
                return BadRequest("Invalid id");
            }

            if (task.Status == null) { return BadRequest("Must include status"); }
            if (task.Priority == null) { return BadRequest("Must include priority"); }

            var rowsAffected = await _dbManager.ExecuteNonQueryAsync(
                "UPDATE task SET appointment_id = @appointment_id, status = @status, priority = @priority WHERE id = @id;",
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
        [Authorize]
        public async Task<IActionResult> MarkOverdueTask(string id) {
            Guid checkedID;
            try {
                checkedID = new Guid(id);
            } catch {
                return BadRequest("Invalid id");
            }

            var rowsAffected = await _dbManager.ExecuteNonQueryAsync(
                "UPDATE task SET status = @status WHERE id = @id;",
                new NpgsqlParameter("@id", checkedID),
                new NpgsqlParameter("@status", "Overdue"));

            if (rowsAffected == 0) {
                return NotFound("Task was not found");
            }
            return Ok();
        }
    }
}
