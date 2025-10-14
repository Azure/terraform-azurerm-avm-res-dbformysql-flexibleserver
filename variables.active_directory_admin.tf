variable "active_directory_administrator" {
  type = object({
    identity_id = optional(string)
    login       = string
    object_id   = string
    tenant_id   = string
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })
  default     = null
  description = <<-EOT
 - `identity_id` - (Optional) The resource ID of the identity used for AAD Authentication. Defaults to first identitiy assigned to the server.
 - `login` - (Required) The login name of the principal to set as the server administrator.
 - `object_id` - (Required) The ID of the principal to set as the server administrator. For a managed identity, this should be the Client ID of the identity.
 - `tenant_id` - (Required) The Azure Tenant ID.

 ---
 `timeouts` block supports the following:
 - `create` - (Defaults to 30 minutes) Used when creating the MySQL Flexible Server Active Directory Administrator.
 - `read` - (Defaults to 5 minutes) Used when retrieving the MySQL Flexible Server Active Directory Administrator.
 - `update` - (Defaults to 30 minutes) Used when updating the MySQL Flexible Server Active Directory Administrator.
 - `delete` - (Defaults to 30 minutes) Used when deleting the MySQL Flexible Server Active Directory Administrator.
EOT

  # Basic format validations (best-effort). Allow blanks to be caught by required type semantics.
  validation {
    condition = (
      var.active_directory_administrator == null || (
        # object_id must be a GUID format
        can(regex("^[0-9a-fA-F-]{36}$", var.active_directory_administrator.object_id)) &&
        # tenant id must be a GUID format
        can(regex("^[0-9a-fA-F-]{36}$", var.active_directory_administrator.tenant_id))
      )
    )
    error_message = "When provided, active_directory_administrator.object_id and tenant_id must be GUIDs."
  }
}

variable "active_directory_administrator_wait_seconds" {
  type        = number
  default     = 0
  description = "Optional delay (in seconds) to wait after server creation before attempting to configure the Active Directory Administrator. Helps mitigate transient InternalServerError responses sometimes observed immediately after server provisioning while identities propagate. Set, for example, to 60 or 120 if you encounter intermittent creation failures."

  validation {
    condition     = var.active_directory_administrator_wait_seconds >= 0 && var.active_directory_administrator_wait_seconds <= 600
    error_message = "active_directory_administrator_wait_seconds must be between 0 and 600 seconds."
  }
}
