using System.Text.RegularExpressions;

namespace AppointmentScheduler {
    public static class Validation {
        public static bool IsValidEmail(string email) {
            if (string.IsNullOrWhiteSpace(email))
                return false;

            string pattern = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";

            return Regex.IsMatch(email, pattern, RegexOptions.IgnoreCase);
        }

        public static bool IsValidPhone(string phone) {
            if (string.IsNullOrWhiteSpace(phone))
                return false;

            string pattern = "^\\(?([0-9]{3})\\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$";

            return Regex.IsMatch(phone, pattern, RegexOptions.IgnoreCase);
        }
    }
}
