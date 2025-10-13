terraform {
  required_version = "~> 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

provider "azurerm" {
  features {}
}
locals {
  test_regions = ["centralus", "westus2", "eastus2"]
}
## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = "0.3.0"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(local.test_regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.3.0"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = "westus2" # module.regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
}

# A vnet & subnet is required for the private endpoint.
resource "azurerm_virtual_network" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["192.168.0.0/24"]
}

resource "azurerm_subnet" "this" {
  address_prefixes     = ["192.168.0.0/24"]
  name                 = module.naming.subnet.name_unique
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}

resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.this.name
}

resource "random_password" "admin_password" {
  length           = 16
  override_special = "!#$%&*()-_=+[]{}<>:?"
  special          = true
}

module "mysql_server" {
  source = "../../"

  location               = azurerm_resource_group.this.location
  name                   = module.naming.mysql_server.name_unique
  resource_group_name    = azurerm_resource_group.this.name
  administrator_login    = "mysqladmin"
  administrator_password = random_password.admin_password.result
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  # ...
  enable_telemetry = var.enable_telemetry # see variables.tf
  high_availability = {
    mode                      = "ZoneRedundant"
    standby_availability_zone = "1"
  }
  private_endpoints = {
    primary = {
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.this.id]
      subnet_resource_id            = azurerm_subnet.this.id
      subresource_name              = "mysqlServer"
      tags                          = null
    }
  }
  sku_name = "Standard_D4ds_v4"
  tags     = null
  zone     = 1
}

# check "dns" {
#   data "azurerm_private_dns_a_record" "assertion" {
#     name                = module.naming.mysql_server.name_unique
#     zone_name           = "privatelink.mysql.database.azure.com"
#     resource_group_name = azurerm_resource_group.this.name
#   }
#   assert {
#     condition     = one(data.azurerm_private_dns_a_record.assertion.records) == one(module.mysql_server.private_endpoints["primary"].private_service_connection).private_ip_address
#     error_message = "The private DNS A record for the private endpoint is not correct."
#   }
# }
