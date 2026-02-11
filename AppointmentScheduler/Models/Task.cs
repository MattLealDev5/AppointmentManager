namespace AppointmentScheduler.Models {
    public class Task {
        public Guid Id { get; set; }
        public Guid? Appointment_id { get; set; }
        public string? Status { get; set; }
        public string? Priority { get; set; }
    }
}