provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription
}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "main" {
  name = var.project
}

data "azurerm_monitor_diagnostic_categories" "app_env" {
  resource_id = azurerm_container_app_environment.main.id
}

resource "azurerm_container_app_environment" "main" {
  name                = var.project
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  logs_destination    = "azure-monitor"
}

resource "random_pet" "eventhub_auth" {
  prefix = var.project
}

resource "azurerm_eventhub_namespace_authorization_rule" "diagnostics" {
  name                = random_pet.eventhub_auth.id
  namespace_name      = var.eventhub_namespace
  resource_group_name = "alexf-Common"
  listen              = false
  send                = true
  manage              = false
}

resource "random_pet" "diagnostic" {
  prefix = var.project
}

resource "azurerm_monitor_diagnostic_setting" "datadog" {
  name                           = random_pet.diagnostic.id
  target_resource_id             = azurerm_container_app_environment.main.id
  eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.diagnostics.id
  eventhub_name                  = var.eventhub_name

  enabled_log {
    category = "ContainerAppConsoleLogs"
  }
}
