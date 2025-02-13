resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

data "azurerm_client_config" "current" {
}

data "external" "me" {
  program = ["az", "account", "show", "--query", "user"]
}

locals {
  prefix   = join("-", ["tfdemo", "ce"])
  dbfsname = join("", ["dbfs", "ce"]) // dbfs name must not have special chars
  cust1dbfsname = join("",["cust1dfbs", "ce"])

  // tags that are propagated down to all resources
  tags = {
    Environment = "Testing"
    Owner       = lookup(data.external.me.result, "name")
    Epoch       = random_string.naming.result
  }
}

resource "azurerm_resource_group" "dp_rg" {
  name     = "adb-dp-${local.prefix}-rg"
  location = var.location
  tags     = local.tags
}

resource "azurerm_resource_group" "transit_rg" {
  name     = "adb-transit-${local.prefix}-rg"
  location = var.location
  tags     = local.tags
}

resource "azurerm_resource_group" "cust1_dp_rg" {
  name     = "cust1-adb-dp-${local.prefix}-rg"
  location = var.location
  tags     = local.tags
}

