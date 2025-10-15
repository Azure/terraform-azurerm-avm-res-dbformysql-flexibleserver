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
  default     = "8.4"
  description = "Supported MySQL Flexible Server version to deploy. Allowed values: '5.7', '8.4'."
}

variable "public_network_access" {
  type        = string
  default     = "Disabled"
  description = "Whether public network access is allowed for the MySQL Flexible Server. Possible values are 'Enabled' or 'Disabled'."
}
