terraform {
  required_version = ">= 1.0"

  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "group_postfix" {
  type        = string
  description = "Lowercase alphanumeric suffix used in the resource group name."

  validation {
    condition     = can(regex("^[a-z0-9]{1,10}$", var.group_postfix))
    error_message = "group_postfix must contain 1 to 10 lowercase alphanumeric characters."
  }
}

variable "linux_ssh_public_key" {
  type        = string
  description = "Existing SSH public key for the Linux VM admin user. Supply it at runtime from a local .pub file."

  validation {
    condition     = length(trimspace(var.linux_ssh_public_key)) > 0
    error_message = "linux_ssh_public_key must not be empty."
  }
}

locals {
  group_name      = "GH200-${var.group_postfix}"
  location        = "japaneast"
  linux_vm_size   = "Standard_B2s"
  linux_admin     = "azureuser"
  random_str      = "ksh"
  lab_name        = "lab"
  resource_suffix = "${var.group_postfix}-${local.random_str}"

  default_tags = {
    environment     = local.group_name
    SecurityControl = "Ignore"
  }
}

data "azurerm_client_config" "current" {}

resource "random_string" "rid" {
  length  = 3
  special = false
  numeric = false
  upper   = false
}

# resource "random_integer" "rint" {
#   min = 100
#   max = 999
# }

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "rg" {
  name     = local.group_name
  location = local.location

  tags = local.default_tags
}
