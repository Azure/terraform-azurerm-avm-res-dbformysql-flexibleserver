resource "azurerm_mysql_flexible_server_active_directory_administrator" "this" {
  # only create the resource if the user has supplied parameters to var.active_directory_administrator.
  count = var.active_directory_administrator != null ? 1 : 0

  identity_id = coalesce(
    var.active_directory_administrator.identity_id,
    length(azurerm_mysql_flexible_server.this.identity[0].identity_ids) > 0 ? tolist(azurerm_mysql_flexible_server.this.identity[0].identity_ids)[0] : null
  )
  login     = var.active_directory_administrator.login
  object_id = var.active_directory_administrator.object_id
  server_id = azurerm_mysql_flexible_server.this.id
  tenant_id = var.active_directory_administrator.tenant_id

  # Support optional custom timeouts supplied via var.active_directory_administrator.timeouts
  dynamic "timeouts" {
    for_each = try([var.active_directory_administrator.timeouts], [])

    content {
      create = try(timeouts.value.create, null)
      delete = try(timeouts.value.delete, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
    }
  }

  # Explicit dependency to ensure server (and its identities) exist before assigning AAD administrator.
  depends_on = [
    azurerm_mysql_flexible_server.this
  ]
}
