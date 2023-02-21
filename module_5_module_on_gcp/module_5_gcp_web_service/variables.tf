variable "project_id" {
  type        = string
  description = "Project_id"
}

variable "network_name" {
  type        = string
  description = "VPC_network_name"
}

variable "region" {
  type        = string
  description = "region"
}

variable "target_size" {
  type        = number
  description = "The target number of running instances for this managed instance group. This value should always be explicitly set unless this resource is attached to an autoscaler, in which case it should never be set."
}

variable "name" {
  default     = "bespin"
  type        = string
  description = "resource_prefix_name"
}