mock_provider "azapi" {}

mock_provider "azurerm" {
  mock_resource "azurerm_mysql_flexible_server" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mysql-test/providers/Microsoft.DBforMySQL/flexibleServers/mysql-test"
      fqdn = "mysql-test.mysql.database.azure.com"
    }
  }
}

mock_provider "modtm" {}
mock_provider "random" {}
mock_provider "time" {}

variables {
  location               = "eastus2"
  name                   = "mysql-test"
  resource_group_name    = "mysql-test"
  administrator_login    = "mysqladmin"
  administrator_password = "Mock-Only-Password123!"
  enable_telemetry       = false
  sku_name               = "GP_Standard_D2ds_v4"
}

run "defaults" {
  command = apply

  assert {
    condition     = length(azurerm_mysql_flexible_server.this.customer_managed_key) == 0 && length(azurerm_mysql_flexible_server.this.identity) == 0
    error_message = "Omitting encryption and identity inputs must not configure them."
  }

  assert {
    condition     = length(azurerm_private_endpoint.this_managed_dns_zone_groups) == 0 && length(azurerm_private_endpoint.this_unmanaged_dns_zone_groups) == 0
    error_message = "No private endpoint should be created by default."
  }
}

run "primary_encryption" {
  command = apply

  variables {
    customer_managed_key = {
      key_vault_key_id                  = "https://primary.vault.azure.net/keys/mysql/11111111111111111111111111111111"
      primary_user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mysql-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/primary"
    }
    managed_identities = {
      user_assigned_resource_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mysql-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/primary"]
    }
  }

  assert {
    condition = (
      one(azurerm_mysql_flexible_server.this.customer_managed_key).key_vault_key_id == var.customer_managed_key.key_vault_key_id &&
      one(azurerm_mysql_flexible_server.this.customer_managed_key).primary_user_assigned_identity_id == var.customer_managed_key.primary_user_assigned_identity_id &&
      one(azurerm_mysql_flexible_server.this.customer_managed_key).geo_backup_key_vault_key_id == null &&
      one(azurerm_mysql_flexible_server.this.identity).type == "UserAssigned" &&
      one(azurerm_mysql_flexible_server.this.identity).identity_ids == var.managed_identities.user_assigned_resource_ids
    )
    error_message = "The primary key URI and encryption identity must reach the server unchanged."
  }
}

run "geo_backup_encryption" {
  command = apply

  variables {
    customer_managed_key = {
      key_vault_key_id                     = "https://primary.vault.azure.net/keys/mysql/11111111111111111111111111111111"
      primary_user_assigned_identity_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mysql-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/primary"
      geo_backup_key_vault_key_id          = "https://backup.vault.azure.net/keys/mysql/22222222222222222222222222222222"
      geo_backup_user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mysql-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/backup"
    }
    managed_identities = {
      user_assigned_resource_ids = [
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mysql-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/primary",
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mysql-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/backup",
      ]
    }
  }

  assert {
    condition = (
      one(azurerm_mysql_flexible_server.this.customer_managed_key).key_vault_key_id == var.customer_managed_key.key_vault_key_id &&
      one(azurerm_mysql_flexible_server.this.customer_managed_key).primary_user_assigned_identity_id == var.customer_managed_key.primary_user_assigned_identity_id &&
      one(azurerm_mysql_flexible_server.this.customer_managed_key).geo_backup_key_vault_key_id == var.customer_managed_key.geo_backup_key_vault_key_id &&
      one(azurerm_mysql_flexible_server.this.customer_managed_key).geo_backup_user_assigned_identity_id == var.customer_managed_key.geo_backup_user_assigned_identity_id &&
      one(azurerm_mysql_flexible_server.this.identity).identity_ids == var.managed_identities.user_assigned_resource_ids
    )
    error_message = "Primary and geo-backup keys and identities must remain distinct and assigned."
  }
}

run "managed_endpoint_default_service" {
  command = apply

  variables {
    private_endpoints = {
      primary = {
        subnet_resource_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mysql-test/providers/Microsoft.Network/virtualNetworks/test/subnets/private"
        private_dns_zone_resource_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mysql-test/providers/Microsoft.Network/privateDnsZones/privatelink.mysql.database.azure.com"]
        ip_configurations = {
          primary = {
            name               = "primary"
            private_ip_address = "10.0.0.4"
          }
        }
      }
    }
  }

  assert {
    condition = (
      length(azurerm_private_endpoint.this_unmanaged_dns_zone_groups) == 0 &&
      one(one(azurerm_private_endpoint.this_managed_dns_zone_groups["primary"].private_service_connection).subresource_names) == "mysqlServer" &&
      one(azurerm_private_endpoint.this_managed_dns_zone_groups["primary"].private_service_connection).private_connection_resource_id == azurerm_mysql_flexible_server.this.id &&
      one(azurerm_private_endpoint.this_managed_dns_zone_groups["primary"].ip_configuration).member_name == "mysqlServer" &&
      one(azurerm_private_endpoint.this_managed_dns_zone_groups["primary"].ip_configuration).subresource_name == "mysqlServer" &&
      toset(one(azurerm_private_endpoint.this_managed_dns_zone_groups["primary"].private_dns_zone_group).private_dns_zone_ids) == var.private_endpoints.primary.private_dns_zone_resource_ids
    )
    error_message = "The single MySQL service must be the default for managed endpoints and static IP configurations."
  }
}

run "unmanaged_endpoint_default_service" {
  command = apply

  variables {
    private_endpoints_manage_dns_zone_group = false
    private_endpoints = {
      primary = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mysql-test/providers/Microsoft.Network/virtualNetworks/test/subnets/private"
        ip_configurations = {
          primary = {
            name               = "primary"
            private_ip_address = "10.0.0.4"
          }
        }
      }
    }
  }

  assert {
    condition = (
      length(azurerm_private_endpoint.this_managed_dns_zone_groups) == 0 &&
      one(one(azurerm_private_endpoint.this_unmanaged_dns_zone_groups["primary"].private_service_connection).subresource_names) == "mysqlServer" &&
      one(azurerm_private_endpoint.this_unmanaged_dns_zone_groups["primary"].ip_configuration).member_name == "mysqlServer" &&
      one(azurerm_private_endpoint.this_unmanaged_dns_zone_groups["primary"].ip_configuration).subresource_name == "mysqlServer" &&
      length(azurerm_private_endpoint.this_unmanaged_dns_zone_groups["primary"].private_dns_zone_group) == 0
    )
    error_message = "Unmanaged endpoints must use the MySQL service without creating a DNS zone group when no zones are supplied."
  }
}

run "explicit_endpoint_service" {
  command = apply

  variables {
    private_endpoints = {
      primary = {
        subresource_name   = "mysqlServer"
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mysql-test/providers/Microsoft.Network/virtualNetworks/test/subnets/private"
        ip_configurations = {
          primary = {
            name               = "primary"
            private_ip_address = "10.0.0.4"
            member_name        = "custom-member"
          }
        }
      }
    }
  }

  assert {
    condition = (
      one(one(azurerm_private_endpoint.this_managed_dns_zone_groups["primary"].private_service_connection).subresource_names) == "mysqlServer" &&
      one(azurerm_private_endpoint.this_managed_dns_zone_groups["primary"].ip_configuration).member_name == "custom-member" &&
      one(azurerm_private_endpoint.this_managed_dns_zone_groups["primary"].ip_configuration).subresource_name == "mysqlServer"
    )
    error_message = "Explicit service names must remain supported and an explicit IP member name must be honored."
  }
}
