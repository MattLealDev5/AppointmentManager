using System.Security.Cryptography;
using AppointmentScheduler.Controllers;
using AppointmentScheduler.Models;
using AppointmentScheduler.Repositories;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Moq;
using Npgsql;

namespace AppointmentScheduler.Tests;

public class AuthControllerTests {
    private readonly Mock<IDatabaseManager> _mockDb;
    private readonly IConfiguration _configuration;
    private readonly AuthController _controller;

    public AuthControllerTests() {
        _mockDb = new Mock<IDatabaseManager>();

        var configData = new Dictionary<string, string?> {
            { "Jwt:Key", "ThisIsA32CharMinimumSecretKey!!!" },
            { "Jwt:Issuer", "AppointmentScheduler" },
            { "Jwt:Audience", "AppointmentSchedulerUsers" },
            { "Jwt:ExpireMinutes", "60" }
        };
        _configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(configData)
            .Build();

        _controller = new AuthController(_mockDb.Object, _configuration);
    }

    [Fact]
    public async Task Register_ValidRequest_ReturnsCreated() {
        // Arrange
        var request = new RegisterRequest {
            Username = "testuser",
            Password = "SecurePass123",
            Role = "FrontDesk",
            Email = "test@example.com",
            Phone = "123-456-7890"
        };

        _mockDb.Setup(db => db.ExecuteScalarAsync<object>(
                It.IsAny<string>(),
                It.IsAny<NpgsqlParameter[]>()))
            .ReturnsAsync((object?)null);

        _mockDb.Setup(db => db.ExecuteNonQueryAsync(
                It.IsAny<string>(),
                It.IsAny<NpgsqlParameter[]>()))
            .ReturnsAsync(1);

        // Act
        var result = await _controller.Register(request);

        // Assert
        var createdResult = Assert.IsType<CreatedAtActionResult>(result);
        Assert.Equal(201, createdResult.StatusCode);

        var value = createdResult.Value;
        var usernameProperty = value!.GetType().GetProperty("Username");
        var roleProperty = value.GetType().GetProperty("Role");
        Assert.Equal("testuser", usernameProperty!.GetValue(value));
        Assert.Equal("FrontDesk", roleProperty!.GetValue(value));
    }

    [Fact]
    public async Task Login_ValidCredentials_ReturnsToken() {
        // Arrange
        var password = "SecurePass123";
        var hashedPassword = HashPassword(password);

        var mockUser = new User {
            Id = Guid.NewGuid(),
            Username = "testuser",
            PasswordHash = hashedPassword,
            Role = "FrontDesk"
        };

        _mockDb.Setup(db => db.ExecuteReaderAsync(
                It.IsAny<string>(),
                It.IsAny<Func<NpgsqlDataReader, User>>(),
                It.IsAny<NpgsqlParameter[]>()))
            .ReturnsAsync(new List<User> { mockUser });

        var request = new LoginRequest {
            Username = "testuser",
            Password = password
        };

        // Act
        var result = await _controller.Login(request);

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result);
        Assert.Equal(200, okResult.StatusCode);

        var tokenProperty = okResult.Value!.GetType().GetProperty("token");
        var token = tokenProperty!.GetValue(okResult.Value) as string;
        Assert.False(string.IsNullOrEmpty(token));
    }

    private static string HashPassword(string password) {
        var salt = RandomNumberGenerator.GetBytes(16);
        var hash = Rfc2898DeriveBytes.Pbkdf2(password, salt, 100000, HashAlgorithmName.SHA256, 32);
        return Convert.ToBase64String(salt) + ":" + Convert.ToBase64String(hash);
    }
}
