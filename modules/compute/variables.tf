variable "name" {
  description = "Name prefix for compute resources."
  type        = string
}

variable "region" {
  description = "Region of the managed instance group."
  type        = string
}

variable "zones" {
  description = "Zones instances are distributed across."
  type        = list(string)
}

variable "subnetwork_self_link" {
  description = "Subnet the instances attach to."
  type        = string
}

variable "service_account_email" {
  description = "Service account attached to the instances."
  type        = string
}

variable "machine_type" {
  description = "Machine type of each instance."
  type        = string
}

variable "boot_disk_size_gb" {
  description = "Boot disk size in GB."
  type        = number
}

variable "min_replicas" {
  description = "Autoscaler minimum."
  type        = number
}

variable "max_replicas" {
  description = "Autoscaler maximum."
  type        = number
}

variable "cpu_target" {
  description = "Target average CPU utilization (0-1)."
  type        = number
}

variable "assets_bucket" {
  description = "Name of the assets bucket, passed to instances as metadata."
  type        = string
}

variable "labels" {
  description = "Labels applied to the template and disks."
  type        = map(string)
  default     = {}
}
