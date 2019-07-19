##############################################
##              Azure Backend               ##
##############################################

data "azurerm_key_vault" "central_kv" {
    name                = "crossteamsecrets"
    resource_group_name = "tf-pg-mcg"
}

data "azurerm_key_vault_secret" "ghost-sql" {
    name                = "ghost-sqlpwd"
    key_vault_id        = data.azurerm_key_vault.central_kv.id
}

# Use to provision MySQL backend for ghost
resource "azurerm_mysql_server" "ghost-be" {
    name                = "ghost-backend"
    location            = var.loc
    resource_group_name = azurerm_resource_group.ghost-rg.name

    sku {
        name            = "B_Gen5_2"
        capacity        = 2
        tier            = "Basic"
        family          = "Gen5"
    }

    storage_profile {
        storage_mb              = 20480
        backup_retention_days   = 7
        geo_redundant_backup    = "Disabled"
    }

    administrator_login             = var.sqladmin
    administrator_login_password    = data.azurerm_key_vault_secret.ghost-sql.value
    version                         = "5.7"
    ssl_enforcement                 = "Disabled"
}

resource "azurerm_mysql_database" "ghost" {
    name                = "ghost"
    resource_group_name = azurerm_resource_group.ghost-rg.name
    server_name         = azurerm_mysql_server.ghost-be.name
    charset             = "utf8"
    collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_firewall_rule" "ghost" {
    name                = "ghost-fw-http-rule"
    resource_group_name = azurerm_resource_group.ghost-rg.name
    server_name         = azurerm_mysql_server.ghost-be.name
    start_ip_address    = "0.0.0.0"
    end_ip_address      = "0.0.0.0"
}