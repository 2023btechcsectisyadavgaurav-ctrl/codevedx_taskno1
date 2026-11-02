variable "name" {
  description = "Name prefix (also used as the service account ID, so it must be 6-30 chars when suffixed)."
  type        = string
}

variable "project_id" {
  description = "Project that receives the IAM bindings."
  type        = string
}

variable "network_name" {
  description = "VPC the firewall rules are attached to."
  type        = string
}

variable "subnet_cidr" {
  description = "Subnet CIDR allowed to talk to itself."
  type        = string
}

variable "enable_iap_ssh" {
  description = "Create the IAP-only SSH firewall rule."
  type        = bool
  default     = true
}
