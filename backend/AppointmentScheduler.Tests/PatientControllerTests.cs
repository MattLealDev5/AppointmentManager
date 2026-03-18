using AppointmentScheduler.Controllers;
using AppointmentScheduler.Models;
using AppointmentScheduler.Repositories;
using Microsoft.AspNetCore.Mvc;
using Moq;
using Npgsql;

namespace AppointmentScheduler.Tests {
    public class PatientControllerTests {
        private readonly Mock<IDatabaseManager> _mockDb;
        private readonly PatientController _controller;

        public PatientControllerTests() {
            _mockDb = new Mock<IDatabaseManager>();
            _controller = new PatientController(_mockDb.Object);
        }

        [Fact]
        public async Task GetPatients_ValidRequest_ReturnsOk() {
            // Arrange
            var mockPatients = new List<Patient> {
                new Patient {
                    Id = Guid.NewGuid(),
                    Name = "John Doe",
                    Date_of_birth = new DateTime(1990, 1, 15),
                    Email = "john@example.com"
                },
                new Patient {
                    Id = Guid.NewGuid(),
                    Name = "Jane Smith",
                    Date_of_birth = new DateTime(1985, 6, 20),
                    Email = "jane@example.com"
                }
            };

            _mockDb.Setup(db => db.ExecuteReaderAsync(
                    It.IsAny<string>(),
                    It.IsAny<Func<NpgsqlDataReader, Patient>>(),
                    It.IsAny<NpgsqlParameter[]>()))
                .ReturnsAsync(mockPatients);

            // Act
            var result = await _controller.GetPatients();

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var patients = Assert.IsType<List<Patient>>(okResult.Value);
            Assert.Equal(2, patients.Count);
            Assert.Equal("John Doe", patients[0].Name);
            Assert.Equal("Jane Smith", patients[1].Name);
        }

        [Fact]
        public async Task GetPatientID_ValidRequest_ReturnsOk() {
            // Arrange
            var mockPatient = new List<Patient> {
                new Patient {
                    Id = Guid.NewGuid(),
                    Name = "John Doe",
                    Date_of_birth = new DateTime(1990, 1, 15),
                    Email = "john@example.com"
                }
            };

            _mockDb.Setup(db => db.ExecuteReaderAsync(
                    It.IsAny<string>(),
                    It.IsAny<Func<NpgsqlDataReader, Patient>>(),
                    It.IsAny<NpgsqlParameter[]>()))
                .ReturnsAsync(mockPatient);

            // Act
            var result = await _controller.GetPatientID(mockPatient[0].Id.ToString());

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var patientWithID = Assert.IsType<List<Patient>>(okResult.Value);
            Assert.Single(patientWithID);
            Assert.Equal("John Doe", patientWithID[0].Name);
        }

        [Fact]
        public async Task PostPatient_ValidPatient_ReturnsCreated() {
            var patient = new Patient {
                Id = Guid.NewGuid(),
                Name = "Jimmy",
                Date_of_birth = new DateTime(1990, 1, 15),
                Email = "jimmy@email.com"
            };

            _mockDb.Setup(db => db.ExecuteNonQueryAsync(
                    It.IsAny<string>(),
                    It.IsAny<NpgsqlParameter[]>()))
                .ReturnsAsync(1);


            var result = await _controller.CreatePatient(patient);

            var createdResult = Assert.IsType<CreatedAtActionResult>(result);
            Assert.Equal(201, createdResult.StatusCode);

            var createdPatient = Assert.IsType<Patient>(createdResult.Value);
            Assert.Equal("Jimmy", createdPatient.Name);
        }

        [Fact]
        public async Task PutPatient_ValidPatient_ReturnsEdited()
        {
            var patient = new Patient
            {
                Id = Guid.NewGuid(),
                Name = "Jimmy",
                Date_of_birth = new DateTime(1990, 1, 15),
                Email = "jimmy@email.com"
            };

            _mockDb.Setup(db => db.ExecuteNonQueryAsync(
                    It.IsAny<string>(),
                    It.IsAny<NpgsqlParameter[]>()))
                .ReturnsAsync(1);

            var result = await _controller.EditPatient(Guid.NewGuid().ToString(), patient);

            var okResult = Assert.IsType<OkObjectResult>(result);
            var editedPatient = Assert.IsType<Patient>(okResult.Value);
            Assert.Equal("Jimmy", editedPatient.Name);
        }
    }
}
