provider "azurerm" {
  version = "1.5.0"
  subscription_id = "${var.terraform_azure_service_principal_subscription_id}"
  client_id       = "${var.terraform_azure_service_principal_client_id}"
  client_secret   = "${var.terraform_azure_service_principal_client_secret}"
  tenant_id       = "${var.terraform_azure_service_principal_tenant_id}"
}

provider "kubernetes" {
  host                   = "${azurerm_kubernetes_cluster.k8s.kube_config.0.host}"
  username               = "${azurerm_kubernetes_cluster.k8s.kube_config.0.username}"
  password               = "${azurerm_kubernetes_cluster.k8s.kube_config.0.password}"
  client_certificate     = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)}"
  client_key             = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)}"
  cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)}"  
}

