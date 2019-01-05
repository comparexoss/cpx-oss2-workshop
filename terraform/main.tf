provider "azurerm" {
  version = "=1.5.0"
  subscription_id = "db29d5ad-1fbb-4443-b3c5-94c79b4250dc"
  client_id       = "07e3e541-57d3-4591-b7eb-705da6838259"
  client_secret   = "5d1c2325-5493-425f-aee5-e37fb2ffffa6"
  tenant_id       = "bd200d3d-aa96-41ae-8c56-0bd57c973985"
}

provider "kubernetes" {
  host                   = "${azurerm_kubernetes_cluster.k8s.kube_config.0.host}"
  username               = "${azurerm_kubernetes_cluster.k8s.kube_config.0.username}"
  password               = "${azurerm_kubernetes_cluster.k8s.kube_config.0.password}"
  client_certificate     = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)}"
  client_key             = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)}"
  cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)}"  
}

