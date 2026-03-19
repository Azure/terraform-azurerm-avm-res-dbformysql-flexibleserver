output "resource_id" {
  description = "The ID of the resoure"
  value       = azurerm_mysql_flexible_server.this.id
}

output "resource_fqdn" {
  description = "The fully qualified domain name of the MySQL Flexible Server."
  value       = azurerm_mysql_flexible_server.this.fqdn
}

output "resource_name" {
  description = "The name of the resource"
  value       = azurerm_mysql_flexible_server.this.name
}
