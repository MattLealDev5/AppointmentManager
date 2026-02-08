namespace AppointmentScheduler.Models {
    public class Appointment {
        public Guid Id { get; set; }
        public Guid Patient_id { get; set; }
        public DateTime? Date { get; set; }
        public string? Type { get; set; }
    }
}
