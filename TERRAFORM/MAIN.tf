terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "group_postfix" {
  type = string
}

variable "user_name" {
  type    = string
  default = "demouser"
}

variable "user_passowrd" {
  type    = string
  default = "Azuredemo2020"
}

locals {
  group_name    = "GH200-${var.group_postfix}"
  location      = "japaneast"
  vm_size       = "Standard_B4ms"
  random_str    = "ksh"
  admin_oid     = "b8e50bc5-6559-4643-a003-2807a8d707f7"
  lab_name      = "lab"
  lab01_name    = "lab01"
  lab01a_name   = "lab01a"
  lab01b_name   = "lab01b"
  lab01c_name   = "lab01c"
  lab01d_name   = "lab01d"
  lab01e_name   = "lab01e"
  lab01f_name   = "lab01f"
  lab01g_name   = "lab01g"
  lab01h_name   = "lab01h"
  lab02_name    = "lab02"
  lab03_name    = "lab03"
  lab04_name    = "lab04"
  lab05_name    = "lab05"
  lab06_name    = "lab06"
  lab07_name    = "lab07"
  user_name     = "demouser"
  user_passowrd = "Azuredemo2020"

  default_tags = {
    environment = local.group_name
    SecurityControl = "Ignore"
  }
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
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
