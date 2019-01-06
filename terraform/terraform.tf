# create a resource group if it doesn't exist
resource "azurerm_resource_group" "k8s" {
  name     = "${var.terraform_azure_resource_group}"
  location = "${var.terraform_azure_region}"
}

# create azure container service (aks)
resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${var.terrafform_aks_name}"
  location            = "${azurerm_resource_group.k8s.location}"
  resource_group_name = "${azurerm_resource_group.k8s.name}"
  dns_prefix          = "${var.terrafform_aks_name}"
  kubernetes_version  = "${var.terraform_aks_kubernetes_version}"

  agent_pool_profile {
    name    = "agentpool"
    count   = "${var.terraform_aks_agent_vm_count}"
    vm_size = "${var.terraform_aks_vm_size}"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }
  
    linux_profile {
    admin_username = "${var.terraform_azure_admin_name}"
    ssh_key {
      key_data = "${file("${var.terraform_azure_ssh_key}")}"
    }
  }
   
  service_principal {
    client_id     = "${var.terraform_azure_service_principal_client_id}"
    client_secret = "${var.terraform_azure_service_principal_client_secret}"
  }
  
   tags {
        Environment = "Development"
    }
}

    resource "null_resource" "az_login" {
      provisioner "local-exec" {
      command = "az login --service-principal --username ${var.terraform_azure_service_principal_client_id} --password ${var.terraform_azure_service_principal_client_secret} --tenant ${var.terraform_azure_service_principal_tenant_id}"
      }
      depends_on = ["azurerm_kubernetes_cluster.k8s"]
    }
    resource "null_resource" "get_config" {
      provisioner "local-exec" {
        command = "az aks get-credentials --resource-group=${var.terraform_azure_resource_group} --name=${var.terrafform_aks_name}"
      }
      depends_on = ["null_resource.az_login"]
    }
    resource "null_resource" "create_tiller_serviceaccount" {
      provisioner "local-exec" {
        command = "sudo kubectl create serviceaccount --namespace kube-system tiller"
      }
      depends_on = ["null_resource.get_config"]
    }
    resource "null_resource" "create_tiller_clusterrolebinding" {
      provisioner "local-exec" {
        command = "sudo kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller"
      }
      depends_on = ["null_resource.create_tiller_serviceaccount"]
    }
    resource "null_resource" "patch_deploy" {
      provisioner "local-exec" {
        command = "sudo kubectl patch deploy --namespace kube-system tiller-deploy -p '{\"spec\":{\"template\":{\"spec\":{\"serviceAccount\":\"tiller\"}}}}'"
      }
      depends_on = ["null_resource.create_tiller_serviceaccount"]
    }
    resource "null_resource" "helm_init" {
      provisioner "local-exec" {
        command = "sudo /usr/local/bin/helm init --service-account tiller"
      }
      depends_on = ["null_resource.patch_deploy"]
    }
