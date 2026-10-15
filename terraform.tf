terraform {
  required_version = ">= 1.3.0 , < 2.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.6"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.11.1, < 2.0.0"
    }
  }
}
