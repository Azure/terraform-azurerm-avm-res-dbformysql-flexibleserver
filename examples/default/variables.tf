variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "mysql_version" {
  type        = string
  default     = "8.0.21"
  description = "The MySQL Flexible Server version to deploy. Supported values are `5.7`, `8.0.21`, and `8.4`. Azure accepts `8.0.21` for the MySQL 8.0 line and manages minor version updates. The example defaults to `8.0.21`."
}

variable "public_network_access" {
  type        = string
  default     = "Disabled"
  description = "Whether public network access is allowed for the MySQL Flexible Server. Possible values are 'Enabled' or 'Disabled'."
}
