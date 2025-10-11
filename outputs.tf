
output "resouce_name" {
  description = "The name of the rresource"
  value       = azurerm_mysql_flexible_server.this.name
}

# Module owners should include the full resource via a 'resource' output
# https://azure.github.io/Azure-Verified-Modules/specs/terraform/#id-tffr2---category-outputs---additional-terraform-outputs
output "resource" {
  description = "This is the full output for the resource."
  value       = azurerm_mysql_flexible_server.this
}

output "resource_id" {
  description = "The ID of the resoure"
  value       = azurerm_mysql_flexible_server.this.id
}
