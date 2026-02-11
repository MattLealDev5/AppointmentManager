namespace AppointmentScheduler.Models {
    public class TaskItem {
        public Guid Id { get; set; }
        public Guid? Appointment_id { get; set; }
        public string? Status { get; set; }
        public string? Priority { get; set; }
    }
}