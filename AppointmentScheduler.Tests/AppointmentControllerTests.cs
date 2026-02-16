using AppointmentScheduler.Controllers;
using AppointmentScheduler.Models;
using AppointmentScheduler.Repositories;
using Microsoft.AspNetCore.Mvc;
using Moq;
using Npgsql;

namespace AppointmentScheduler.Tests {
    public class AppointmentControllerTests {
        private readonly Mock<IDatabaseManager> _mockDb;
        private readonly AppointmentController _controller;

        public AppointmentControllerTests() {
            _mockDb = new Mock<IDatabaseManager>();
            _controller = new AppointmentController(_mockDb.Object);
        }

        [Fact]
        public async Task GetAppointments_ValidRequest_ReturnsOk() {
            // Arrange
            var mockAppointments = new List<Appointment> {
                new Appointment {
                    Id = Guid.NewGuid(),
                    Patient_id = Guid.NewGuid(),
                    Date = new DateTime(2027, 1, 15),
                    Type = "reason"
                },
                new Appointment {
                    Id = Guid.NewGuid(),
                    Patient_id = Guid.NewGuid(),
                    Date = new DateTime(2028, 6, 20),
                    Type = "no reason"
                }
            };

            _mockDb.Setup(db => db.ExecuteReaderAsync(
                    It.IsAny<string>(),
                    It.IsAny<Func<NpgsqlDataReader, Appointment>>(),
                    It.IsAny<NpgsqlParameter[]>()))
                .ReturnsAsync(mockAppointments);

            // Act
            var result = await _controller.GetAppointments();

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var appointments = Assert.IsType<List<Appointment>>(okResult.Value);
            Assert.Equal(2, appointments.Count);
            Assert.Equal("reason", appointments[0].Type);
            Assert.Equal("no reason", appointments[1].Type);
        }

        [Fact]
        public async Task GetAppointmentPID_ValidRequest_ReturnsOk() {
            // Arrange
            var mockAppointment = new List<Appointment> {
                new Appointment {
                    Id = Guid.NewGuid(),
                    Patient_id = Guid.NewGuid(),
                    Date = new DateTime(2027, 1, 15),
                    Type = "reason"
                }
            };

            _mockDb.Setup(db => db.ExecuteReaderAsync(
                    It.IsAny<string>(),
                    It.IsAny<Func<NpgsqlDataReader, Appointment>>(),
                    It.IsAny<NpgsqlParameter[]>()))
                .ReturnsAsync(mockAppointment);

            // Act
            var result = await _controller.GetAppointmentsPID(mockAppointment[0].Patient_id.ToString());

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var appointment = Assert.IsType<List<Appointment>>(okResult.Value);
            Assert.Single(appointment);
            Assert.Equal("reason", appointment[0].Type);
        }

        [Fact]
        public async Task PostAppointment_ValidAppointment_ReturnsCreated() {
            var appointment = new Appointment {
                Id = Guid.NewGuid(),
                Patient_id = Guid.NewGuid(),
                Date = new DateTime(2027, 1, 15),
                Type = "reason"
            };

            _mockDb.Setup(db => db.ExecuteNonQueryAsync(
                    It.IsAny<string>(),
                    It.IsAny<NpgsqlParameter[]>()))
                .ReturnsAsync(1);


            var result = await _controller.CreateAppointment(appointment);

            var createdResult = Assert.IsType<CreatedAtActionResult>(result);
            Assert.Equal(201, createdResult.StatusCode);

            var createdAppointment = Assert.IsType<Appointment>(createdResult.Value);
            Assert.Equal("reason", createdAppointment.Type);
        }

        [Fact]
        public async Task PutAppointment_ValidAppointment_ReturnsEdited() {
            var appointment = new Appointment {
                Id = Guid.NewGuid(),
                Patient_id = Guid.NewGuid(),
                Date = new DateTime(2027, 1, 15),
                Type = "reason"
            };

            _mockDb.Setup(db => db.ExecuteNonQueryAsync(
                    It.IsAny<string>(),
                    It.IsAny<NpgsqlParameter[]>()))
                .ReturnsAsync(1);

            var result = await _controller.EditPatient(Guid.NewGuid().ToString(), appointment);

            var okResult = Assert.IsType<OkObjectResult>(result);
            var editedAppointment = Assert.IsType<Appointment>(okResult.Value);
            Assert.Equal("reason", editedAppointment.Type);
        }

        [Fact]
        public async Task DeleteAppointment_ValidAppointment_ReturnsNoContent() {
            _mockDb.Setup(db => db.ExecuteNonQueryAsync(
                    It.IsAny<string>(),
                    It.IsAny<NpgsqlParameter[]>()))
                .ReturnsAsync(1);

            var result = await _controller.DeleteAppointment(Guid.NewGuid().ToString());

            Assert.IsType<NoContentResult>(result);
        }
    }
}
