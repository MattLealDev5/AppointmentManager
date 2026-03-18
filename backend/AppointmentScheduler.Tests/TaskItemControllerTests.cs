using AppointmentScheduler.Controllers;
using AppointmentScheduler.Models;
using AppointmentScheduler.Repositories;
using Microsoft.AspNetCore.Mvc;
using Moq;
using Npgsql;

namespace AppointmentScheduler.Tests {
    public class TaskItemControllerTests {
        private readonly Mock<IDatabaseManager> _mockDb;
        private readonly TaskItemController _controller;

        public TaskItemControllerTests() {
            _mockDb = new Mock<IDatabaseManager>();
            _controller = new TaskItemController(_mockDb.Object);
        }

        [Fact]
        public async Task GetTasks_ValidRequest_ReturnsOk() {
            // Arrange
            var mockTask = new List<TaskItem> {
                new TaskItem {
                    Id = Guid.NewGuid(),
                    Appointment_id = Guid.NewGuid(),
                    Status = "going",
                    Priority = "please"
                },
                new TaskItem {
                    Id = Guid.NewGuid(),
                    Appointment_id = Guid.NewGuid(),
                    Status = "yes",
                    Priority = "no"
                }
            };

            _mockDb.Setup(db => db.ExecuteReaderAsync(
                    It.IsAny<string>(),
                    It.IsAny<Func<NpgsqlDataReader, TaskItem>>(),
                    It.IsAny<NpgsqlParameter[]>()))
                .ReturnsAsync(mockTask);

            // Act
            var result = await _controller.GetTasks();

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var tasks = Assert.IsType<List<TaskItem>>(okResult.Value);
            Assert.Equal(2, tasks.Count);
            Assert.Equal("going", tasks[0].Status);
            Assert.Equal("yes", tasks[1].Status);
        }

        [Fact]
        public async Task GetTaskStatus_ValidRequest_ReturnsOk() {
            // Arrange
            var mockTask = new List<TaskItem> {
                new TaskItem {
                    Id = Guid.NewGuid(),
                    Appointment_id = Guid.NewGuid(),
                    Status = "going",
                    Priority = "please"
                }
            };

            _mockDb.Setup(db => db.ExecuteReaderAsync(
                    It.IsAny<string>(),
                    It.IsAny<Func<NpgsqlDataReader, TaskItem>>(),
                    It.IsAny<NpgsqlParameter[]>()))
                .ReturnsAsync(mockTask);

            // Act
            var result = await _controller.GetTaskStatus(mockTask[0].Status);

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var task = Assert.IsType<List<TaskItem>>(okResult.Value);
            Assert.Single(task);
            Assert.Equal("going", task[0].Status);
        }

        [Fact]
        public async Task PutTask_ValidTask_ReturnsEdited() {
            var mockTask = new TaskItem {
                Id = Guid.NewGuid(),
                Appointment_id = Guid.NewGuid(),
                Status = "going",
                Priority = "please"
            };

            _mockDb.Setup(db => db.ExecuteNonQueryAsync(
                    It.IsAny<string>(),
                    It.IsAny<NpgsqlParameter[]>()))
                .ReturnsAsync(1);

            var result = await _controller.EditTask(Guid.NewGuid().ToString(), mockTask);

            var okResult = Assert.IsType<OkObjectResult>(result);
            var editedTask = Assert.IsType<TaskItem>(okResult.Value);
            Assert.Equal("going", editedTask.Status);
        }

        [Fact]
        public async Task PutTaskOverdue_ValidTask_ReturnsEdited() {
            _mockDb.Setup(db => db.ExecuteNonQueryAsync(
                    It.IsAny<string>(),
                    It.IsAny<NpgsqlParameter[]>()))
                .ReturnsAsync(1);

            var result = await _controller.MarkOverdueTask(Guid.NewGuid().ToString());

            Assert.IsType<OkResult>(result);
        }
    }
}
