provider "azurerm" {
    subscription_id = "db29d5ad-1fbb-4443-b3c5-94c79b4250dc"
    client_id       = "07e3e541-57d3-4591-b7eb-705da6838259"
    client_secret   = "5d1c2325-5493-425f-aee5-e37fb2ffffa6"
    tenant_id       = "bd200d3d-aa96-41ae-8c56-0bd57c973985"
}

# create a resource group if it doesn't exist
resource "azurerm_resource_group" "test" {
  name     = "${var.terraform_azure_resource_group}"
  location = "${var.terraform_azure_region}"
}

# create azure container service (aks)
resource "azurerm_kubernetes_cluster" "test" {
  name                = "${var.terrafform_aks_name}"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  dns_prefix          = "${azurerm_resource_group.test.name}"
  kubernetes_version  = "${var.terraform_aks_kubernetes_version}"

  linux_profile {
    admin_username = "${var.terraform_azure_admin_name}"

    ssh_key {
      key_data = "${var.terraform_azure_ssh_key}"
    }
  }

  agent_pool_profile {
    name    = "agentpool"
    count   = "${var.terraform_aks_agent_vm_count}"
    vm_size = "${var.terraform_aks_vm_size}"
  }

  service_principal {
    client_id     = "${var.terraform_azure_service_principal_client_id}"
    client_secret = "${var.terraform_azure_service_principal_client_secret}"
  }
  
   tags {
        Environment = "Development"
    }
  
}
