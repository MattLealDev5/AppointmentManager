namespace AppointmentScheduler.Models {
    public class Patient {
        public Guid Id { get; set; }
        public string? Name { get; set; }
        public DateTime? Date_of_birth { get; set; }
        public string? Email { get; set; }
    }
}