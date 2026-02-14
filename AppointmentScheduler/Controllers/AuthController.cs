using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using AppointmentScheduler.Models;
using AppointmentScheduler.Repositories;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using Npgsql;

namespace AppointmentScheduler.Controllers {

    [ApiController]
    [Route("[controller]")]
    public class AuthController : ControllerBase {
        private readonly DatabaseManager _dbManager;
        private readonly IConfiguration _configuration;

        public AuthController(DatabaseManager dbManager, IConfiguration configuration) {
            _dbManager = dbManager;
            _configuration = configuration;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request) {
            if (request.Username == null) { return BadRequest("Must include username"); }
            if (request.Password == null) { return BadRequest("Must include password"); }
            if (request.Role == null) { return BadRequest("Must include role"); }
            if (!Validation.IsValidEmail(request.Email)) { return BadRequest("Invalid email"); }
            if (!Validation.IsValidPhone(request.Phone)) { return BadRequest("Invalid phone number"); }

            var validRoles = new[] { "FrontDesk", "ClinicalStaff" };
            if (!validRoles.Contains(request.Role)) {
                return BadRequest("Role must be 'FrontDesk' or 'ClinicalStaff'");
            }

            var existingUser = await _dbManager.ExecuteScalarAsync<object>(
                "SELECT id FROM users WHERE username = @username;",
                new NpgsqlParameter("@username", request.Username));

            if (existingUser != null) {
                return Conflict("Username already exists");
            }

            var user = new User {
                Id = Guid.NewGuid(),
                Username = request.Username,
                PasswordHash = HashPassword(request.Password),
                Role = request.Role,
                Email = request.Email,
                Phone = request.Phone
            };

            await _dbManager.ExecuteNonQueryAsync(
                "INSERT INTO users (id, username, password_hash, role, email, phone) VALUES (@id, @username, @password_hash, @role, @email, @phone);",
                new NpgsqlParameter("@id", user.Id),
                new NpgsqlParameter("@username", user.Username),
                new NpgsqlParameter("@password_hash", user.PasswordHash),
                new NpgsqlParameter("@role", user.Role),
                new NpgsqlParameter("@email", (object?)user.Email ?? DBNull.Value),
                new NpgsqlParameter("@phone", (object?)user.Phone ?? DBNull.Value));

            return CreatedAtAction(nameof(Register), new { id = user.Id }, new { user.Id, user.Username, user.Role });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request) {
            if (request.Username == null) { return BadRequest("Must include username"); }
            if (request.Password == null) { return BadRequest("Must include password"); }

            var users = await _dbManager.ExecuteReaderAsync(
                "SELECT id, username, password_hash, role FROM users WHERE username = @username;",
                reader => new User {
                    Id = reader.GetGuid(0),
                    Username = reader.GetString(1),
                    PasswordHash = reader.GetString(2),
                    Role = reader.GetString(3)
                },
                new NpgsqlParameter("@username", request.Username));

            var user = users.FirstOrDefault();

            if (user == null || !VerifyPassword(request.Password, user.PasswordHash!)) {
                return Unauthorized("Invalid username or password");
            }

            var token = GenerateJwtToken(user);
            return Ok(new { token });
        }

        private string GenerateJwtToken(User user) {
            var key = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]!));
            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new[] {
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Name, user.Username!),
                new Claim(ClaimTypes.Role, user.Role!)
            };

            var token = new JwtSecurityToken(
                issuer: _configuration["Jwt:Issuer"],
                audience: _configuration["Jwt:Audience"],
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(
                    int.Parse(_configuration["Jwt:ExpireMinutes"]!)),
                signingCredentials: credentials);

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        private static string HashPassword(string password) {
            var salt = RandomNumberGenerator.GetBytes(16);
            var hash = Rfc2898DeriveBytes.Pbkdf2(password, salt, 100000, HashAlgorithmName.SHA256, 32);
            return Convert.ToBase64String(salt) + ":" + Convert.ToBase64String(hash);
        }

        private static bool VerifyPassword(string password, string storedHash) {
            var parts = storedHash.Split(':');
            if (parts.Length != 2) return false;

            var salt = Convert.FromBase64String(parts[0]);
            var hash = Convert.FromBase64String(parts[1]);
            var testHash = Rfc2898DeriveBytes.Pbkdf2(password, salt, 100000, HashAlgorithmName.SHA256, 32);

            return CryptographicOperations.FixedTimeEquals(hash, testHash);
        }
    }
}
