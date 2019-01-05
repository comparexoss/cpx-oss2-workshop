variable "terrafform_aks_name" {
  type = "string"
  description = "AKS Cluster Name"
  default = ""
}
variable "terraform_azure_resource_group" {
  type        = "string"
  description = "Azure resource group"
  default     = "mstrdevopsaksrg"
}

variable "terraform_azure_region" {
  type        = "string"
  description = "Azure region for deployment"
  default     = "West Europe"
}

variable "terraform_aks_dns_prefix" {
  type        = "string"
  description = "Master DNS Prefix"
  default     = "devopshkkaks"
}

variable "terraform_aks_agent_vm_count" {
  description = "AKS Agent VM count"
  default     = 2
}

variable "terraform_aks_vm_size" {
  type        = "string"
  description = "Azure VM size"
  default     = "Standard_D2v2"
}

variable "terraform_azure_admin_name" {
  type        = "string"
  description = "Admin username"
  default     = "azureuser"
}

variable "terraform_azure_ssh_key" {
  type        = "string"
  description = "SSH Key"
  default     = ""
}

variable "terraform_azure_service_principal_client_id" {
  type        = "string"
  description = "Service Principal Client ID"
  default     = ""
}

variable "terraform_azure_service_principal_client_secret" {
  type        = "string"
  description = "Service Principal Client Secret"
  default     = ""
}

variable "terraform_aks_kubernetes_version" {
  type        = "string"
  description = "Kubernetes Version"
  default     = "1.8.6"
}
