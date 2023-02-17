variable "project_id" {
  default     = "iaas-demo-208601"
  type        = string
  description = "this is project_id"
}

variable "resource_name" {
  default = {
      prod = {
          "vm_name" = "byungjun-prod-vm",
          "vpc_name" = "byungjun-prod-vpc",
          "subnetwork_name" = "byungjun-prod-sbn"
      },
      dev = {
          "vm_name" = "byungjun-dev-vm",
          "vpc_name" = "byungjun-dev-vpc",
          "subnetwork_name" = "byungjun-dev-sbn"
      }
  }
}


variable "vpc_name" {
  default     = "byungjun-terraform-vpc"
  type        = string
  description = "vpc_network_name"
}

variable "subnetwork_name" {
  default     = "byungjun-terraform-sbn"
  type        = string
  description = "subnetwork_name"
}

variable "vm_name" {
  default = "vm" 
  type        = string
  description = "Test_VM"
}