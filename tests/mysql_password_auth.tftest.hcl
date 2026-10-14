run "setup_password_authenticated_server" {
  command = apply

  variables {
    administrator_login    = "mysqladmin"
    administrator_password = "PasswordSecure123!"
    authentication_type    = "Password"
  }

  assert {
    condition     = azurerm_mysql_flexible_server.this.administrator_login == "mysqladmin"
    error_message = "The administrator login does not match the expected value."
  }

  assert {
    condition     = can(azurerm_mysql_flexible_server.this.fqdn)
    error_message = "The MySQL Flexible Server FQDN was not generated successfully."
  }
}
