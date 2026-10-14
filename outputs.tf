output "resource" {
  description = "This is the full output of the resource, including all attributes. Terraform may reject plans when password authentication is used with \"Output refers to sensitive values\""
  value       = azurerm_mysql_flexible_server.this
  sensitive   = true
}

output "resource_fqdn" {
  description = "The fully qualified domain name of the MySQL Flexible Server."
  value       = azurerm_mysql_flexible_server.this.fqdn
}

output "resource_id" {
  description = "The ID of the resoure"
  value       = azurerm_mysql_flexible_server.this.id
}

output "resource_name" {
  description = "The name of the resource"
  value       = azurerm_mysql_flexible_server.this.name
}

