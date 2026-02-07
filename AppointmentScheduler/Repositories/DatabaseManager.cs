using Npgsql;

namespace AppointmentScheduler.Repositories {
    public class DatabaseManager {
        private readonly string _connectionString;

        public DatabaseManager(IConfiguration configuration) {
            _connectionString = configuration.GetConnectionString("PostgreSQL")
                ?? throw new InvalidOperationException("PostgreSQL connection string not found");
        }

        public NpgsqlConnection CreateConnection() {
            return new NpgsqlConnection(_connectionString);
        }

        public async Task<NpgsqlConnection> CreateOpenConnectionAsync() {
            var connection = new NpgsqlConnection(_connectionString);
            await connection.OpenAsync();
            return connection;
        }

        // Returns a single value from a query (first column of first row)
        public async Task<T?> ExecuteScalarAsync<T>(string sql, params NpgsqlParameter[] parameters) {
            await using var connection = await CreateOpenConnectionAsync();
            await using var command = new NpgsqlCommand(sql, connection);
            command.Parameters.AddRange(parameters);
            var result = await command.ExecuteScalarAsync();
            return result == DBNull.Value ? default : (T?)result;
        }

        // Returns no values from a query (insert, delete)
        public async Task<int> ExecuteNonQueryAsync(string sql, params NpgsqlParameter[] parameters) {
            await using var connection = await CreateOpenConnectionAsync();
            await using var command = new NpgsqlCommand(sql, connection);
            command.Parameters.AddRange(parameters);
            return await command.ExecuteNonQueryAsync();
        }

        // Returns multiple rows from a query
        public async Task<List<T>> ExecuteReaderAsync<T>(string sql, Func<NpgsqlDataReader, T> mapper, params NpgsqlParameter[] parameters) {
            var results = new List<T>();
            await using var connection = await CreateOpenConnectionAsync();
            await using var command = new NpgsqlCommand(sql, connection);
            command.Parameters.AddRange(parameters);
            await using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) {
                results.Add(mapper(reader));
            }
            return results;
        }
    }
}
