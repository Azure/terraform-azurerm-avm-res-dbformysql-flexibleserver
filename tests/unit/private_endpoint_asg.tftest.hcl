mock_provider "azapi" {}

mock_provider "azurerm" {
  mock_resource "azurerm_mysql_flexible_server" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mysql-test/providers/Microsoft.DBforMySQL/flexibleServers/mysql-test"
    }
  }

  mock_resource "azurerm_private_endpoint" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mysql-test/providers/Microsoft.Network/privateEndpoints/primary"
    }
  }
}

mock_provider "time" {}

variables {
  location               = "eastus2"
  name                   = "mysql-test"
  resource_group_name    = "mysql-test"
  administrator_login    = "mysqladmin"
  administrator_password = "Mock-Only-Password123!"
  enable_telemetry       = false
  sku_name               = "GP_Standard_D2ds_v4"
  private_endpoints = {
    primary = {
      subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mysql-test/providers/Microsoft.Network/virtualNetworks/test/subnets/private"
      application_security_group_associations = {
        app = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mysql-test/providers/Microsoft.Network/applicationSecurityGroups/app"
        web = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mysql-test/providers/Microsoft.Network/applicationSecurityGroups/web"
      }
    }
    secondary = {
      subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mysql-test/providers/Microsoft.Network/virtualNetworks/test/subnets/secondary"
      application_security_group_associations = {
        app = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mysql-test/providers/Microsoft.Network/applicationSecurityGroups/secondary"
      }
    }
  }
}

run "managed_dns_asg_associations" {
  command = apply

  override_resource {
    target = azurerm_private_endpoint.this_managed_dns_zone_groups["secondary"]
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mysql-test/providers/Microsoft.Network/privateEndpoints/secondary"
    }
  }

  assert {
    condition = (
      length(azurerm_private_endpoint.this_unmanaged_dns_zone_groups) == 0 &&
      toset(keys(azurerm_private_endpoint_application_security_group_association.this)) == toset(["primary-app", "primary-web", "secondary-app"]) &&
      azurerm_private_endpoint.this_managed_dns_zone_groups["primary"].id != azurerm_private_endpoint.this_managed_dns_zone_groups["secondary"].id
    )
    error_message = "Managed DNS must create every ASG association with stable endpoint/ASG keys and distinct endpoint IDs."
  }

  assert {
    condition = alltrue([
      for pe_key, endpoint in var.private_endpoints : alltrue([
        for asg_key, asg_id in endpoint.application_security_group_associations : (
          azurerm_private_endpoint_application_security_group_association.this["${pe_key}-${asg_key}"].private_endpoint_id == azurerm_private_endpoint.this_managed_dns_zone_groups[pe_key].id &&
          azurerm_private_endpoint_application_security_group_association.this["${pe_key}-${asg_key}"].application_security_group_id == asg_id
        )
      ])
    ])
    error_message = "Each ASG must be associated with its own managed private endpoint without mixing endpoint or ASG keys."
  }
}

run "unmanaged_dns_asg_associations" {
  command = apply

  variables {
    private_endpoints_manage_dns_zone_group = false
  }

  override_resource {
    target = azurerm_private_endpoint.this_unmanaged_dns_zone_groups["secondary"]
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mysql-test/providers/Microsoft.Network/privateEndpoints/secondary"
    }
  }

  assert {
    condition = (
      length(azurerm_private_endpoint.this_managed_dns_zone_groups) == 0 &&
      toset(keys(azurerm_private_endpoint_application_security_group_association.this)) == toset(["primary-app", "primary-web", "secondary-app"]) &&
      azurerm_private_endpoint.this_unmanaged_dns_zone_groups["primary"].id != azurerm_private_endpoint.this_unmanaged_dns_zone_groups["secondary"].id
    )
    error_message = "Unmanaged DNS must create every ASG association with stable endpoint/ASG keys and distinct endpoint IDs."
  }

  assert {
    condition = alltrue([
      for pe_key, endpoint in var.private_endpoints : alltrue([
        for asg_key, asg_id in endpoint.application_security_group_associations : (
          azurerm_private_endpoint_application_security_group_association.this["${pe_key}-${asg_key}"].private_endpoint_id == azurerm_private_endpoint.this_unmanaged_dns_zone_groups[pe_key].id &&
          azurerm_private_endpoint_application_security_group_association.this["${pe_key}-${asg_key}"].application_security_group_id == asg_id
        )
      ])
    ])
    error_message = "Each ASG must be associated with its own unmanaged private endpoint without mixing endpoint or ASG keys."
  }
}
