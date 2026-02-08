using AppointmentScheduler.Models;
using AppointmentScheduler.Repositories;
using Microsoft.AspNetCore.Mvc;
using Npgsql;
using System.Text.RegularExpressions;

namespace AppointmentScheduler.Controllers {

    [ApiController]
    [Route("[controller]")]
    public class AppointmentController : ControllerBase {
        private readonly DatabaseManager _dbManager;

        public AppointmentController(DatabaseManager dbManager) {
            _dbManager = dbManager;
        }


    }
}
