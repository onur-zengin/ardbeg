resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "rg_ardbeg"
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = azurerm_resource_group.rg.location
  name                = cluster_ardbeg
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = ns_ardbeg

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D2_v2"
    node_count = var.system_node_count
  }
  linux_profile {
    admin_username = var.username

    ssh_key {
      key_data = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
    }
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "user_np" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vm_size               = "Standard_DS2_v2"
  node_count            = var.user_node_count
  mode = "User"

  tags = {
    mode = "user"
  }
}

resource "azurerm_container_registry" "acr" {
  location            = azurerm_resource_group.rg.location
  name                = "ardbegregistry"
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"

#  georeplications {
#    location                = "North Europe"
#    zone_redundancy_enabled = true
#    tags                    = {}
#  }
}

resource "azurerm_role_assignment" "acr2aks" {
  principal_id                     = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}