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

# we need the tenant id for the active directory administrator
data "azurerm_client_config" "this" {}

locals {
  test_regions = ["centralus", "eastus", "eastus2", "westus3"]
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
  location = module.regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
}

resource "random_password" "admin_password" {
  length           = 16
  override_special = "!#$%&*()-_=+[]{}<>:?"
  special          = true
}

resource "azurerm_user_assigned_identity" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.user_assigned_identity.name_unique
  resource_group_name = azurerm_resource_group.this.name
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "dbformysql" {
  source = "../../"

  location            = azurerm_resource_group.this.location
  name                = module.naming.mysql_server.name_unique
  resource_group_name = azurerm_resource_group.this.name
  active_directory_administrator = {
    login     = "mysqladmin"
    object_id = "6c8d236c-3463-479b-9e80-25e3dbda8ca0" # the Entra ID Group to be set up as the admin
    tenant_id = data.azurerm_client_config.this.tenant_id
  }
  administrator_login    = "mysqladmin"
  administrator_password = random_password.admin_password.result
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  # ...
  enable_telemetry = var.enable_telemetry # see variables.tf
  high_availability = {
    mode                      = "ZoneRedundant"
    standby_availability_zone = 2
  }
  managed_identities = {
    user_assigned_resource_ids = [
      azurerm_user_assigned_identity.this.id
    ]
  }
  sku_name = "GP_Standard_D2ds_v4"
  tags     = null
  zone     = 1
}
