resource "azurerm_container_group" "ghost" {
    name                        = "ghost"
    location                    = var.loc
    resource_group_name         = azurerm_resource_group.ghost-rg.name
    dns_name_label              = "pnwrider"
    ip_address_type             = "public"
    os_type                     = "linux"
    tags                        = var.tags

    container {
        name                    = "ghost-blog"
        image                   = "ghost:alpine"
        cpu                     = "0.5"
        memory                  = "1.0"

        environment_variables   = {
            database__client                  = "mysql"
            database__connection__host        = azurerm_mysql_server.ghost-be.fqdn               #"ghost-backend.mysql.database.azure.com"
            database__connection__user        = "${var.sqladmin}@${var.mysql}"                   #"pnwAdmin"           #"${var.sqladmin}@${var.mysql}"
            database__connection__database    = azurerm_mysql_database.ghost.name                #"ghost"
        }

        secure_environment_variables = {
            database__connection__password    = data.azurerm_key_vault_secret.ghost-sql.value
        }
    }

    container {
        name                    = "sidecar"
        image                   = "grayzu/envoyproxy-sidecar"
        cpu                     = "0.5"
        memory                  = "1.0"
        ports {
            port     = 80
            protocol = "TCP"
        }
    }
}