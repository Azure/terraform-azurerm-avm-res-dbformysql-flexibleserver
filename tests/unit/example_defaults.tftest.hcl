mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}

mock_provider "azurerm" {}

mock_provider "local" {}

mock_provider "random" {
  mock_resource "random_password" {
    defaults = {
      result = "Mock-Only-Password123!"
    }
  }
}

mock_provider "time" {}

run "default_example_mysql_version" {
  command = apply

  providers = {
    azapi   = azapi
    azurerm = azurerm
    local   = local
    random  = random
    time    = time
  }

  module {
    source = "./examples/default"
  }

  variables {
    enable_telemetry = false
  }

  override_module {
    target  = module.regions
    outputs = {}
  }

  assert {
    condition     = var.mysql_version == "8.0.21"
    error_message = "The default example must continue to request MySQL 8.0.21 when mysql_version is omitted."
  }
}
