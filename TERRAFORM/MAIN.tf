terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.5"
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

variable "user_name" {
  type        = string
  default     = "demouser"
  description = "Local administrator username for the Windows VM."
}

variable "user_password" {
  type        = string
  sensitive   = true
  description = "Local administrator password for the Windows VM. Supply it at runtime."
}

locals {
  group_name      = "GH200-${var.group_postfix}"
  location        = "japaneast"
  vm_size         = "Standard_B4ms"
  random_str      = "ksh"
  lab_name        = "lab"
  resource_suffix = "${var.group_postfix}-${local.random_str}"

  default_tags = {
    environment     = local.group_name
    SecurityControl = "Ignore"
  }
}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"

  # use: data.http.myip.response_body
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
