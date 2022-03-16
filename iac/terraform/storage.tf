resource "random_string" "suffix" {
  length           = 6
  special          = false
  upper            = false
  keepers = {
    resource_group_id = azurerm_resource_group.builder_rg.id
  }
}

resource "azurerm_storage_account" "storage" {
  name                      = "builder${ random_string.suffix.result }"
  resource_group_name       = azurerm_resource_group.builder_rg.name
  location                  = azurerm_resource_group.builder_rg.location

  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = "LRS"
  allow_blob_public_access  = false
  enable_https_traffic_only = true
}


resource "azurerm_storage_container" "image_container" {
  name                  = "images"
  storage_account_name  = azurerm_storage_account.storage.name

  container_access_type = "private"
}

resource "azurerm_role_assignment" "role_assignment" {
  scope                = data.azurerm_subscription.sub.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_windows_virtual_machine.vm.identity[0].principal_id
}
