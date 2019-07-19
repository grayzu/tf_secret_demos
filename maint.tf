resource "azurerm_resource_group" "ghost-rg" {
    name                    = var.rg
    location                = var.loc
    tags                    = var.tags
}