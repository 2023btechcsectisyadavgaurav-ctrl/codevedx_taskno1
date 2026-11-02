variable "project_id" {
  description = "GCP project ID that will hold every resource (the project is the top-level resource group)."
  type        = string
}

variable "region" {
  description = "GCP region for regional resources."
  type        = string
  default     = "us-central1"
}

variable "zones" {
  description = "Zones the web tier is spread across. At least two are required for high availability."
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b", "us-central1-c"]

  validation {
    condition     = length(var.zones) >= 2
    error_message = "Provide at least two zones so the web tier survives a zone outage."
  }

  validation {
    condition     = length(distinct(var.zones)) == length(var.zones)
    error_message = "Zones must be unique."
  }
}

variable "environment" {
  description = "Environment name, used in resource names and labels."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "name_prefix" {
  description = "Prefix for all resource names (lowercase letters, digits, hyphens)."
  type        = string
  default     = "cloudinfra"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,14}$", var.name_prefix))
    error_message = "name_prefix must start with a letter, be 3-15 characters, and use only lowercase letters, digits and hyphens."
  }
}

variable "subnet_cidr" {
  description = "CIDR range of the application subnet."
  type        = string
  default     = "10.10.0.0/24"

  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "subnet_cidr must be a valid CIDR block."
  }
}

variable "machine_type" {
  description = "Compute Engine machine type for the web servers."
  type        = string
  default     = "e2-small"
}

variable "boot_disk_size_gb" {
  description = "Boot disk size for each web server, in GB."
  type        = number
  default     = 20
}

variable "min_replicas" {
  description = "Minimum number of web servers. Must be at least 2 so the tier is never a single point of failure."
  type        = number
  default     = 3

  validation {
    condition     = var.min_replicas >= 2
    error_message = "min_replicas must be at least 2."
  }
}

variable "max_replicas" {
  description = "Maximum number of web servers the autoscaler may create."
  type        = number
  default     = 6

  validation {
    condition     = var.max_replicas >= var.min_replicas
    error_message = "max_replicas must be greater than or equal to min_replicas."
  }
}

variable "cpu_target_utilization" {
  description = "Average CPU utilization (0-1) at which the autoscaler adds instances."
  type        = number
  default     = 0.6

  validation {
    condition     = var.cpu_target_utilization > 0 && var.cpu_target_utilization < 1
    error_message = "cpu_target_utilization must be between 0 and 1 (exclusive)."
  }
}

variable "enable_iap_ssh" {
  description = "Allow SSH to the VMs only through Identity-Aware Proxy (no public SSH)."
  type        = bool
  default     = true
}

variable "bucket_force_destroy" {
  description = "Allow `terraform destroy` to delete the storage bucket even if it contains objects."
  type        = bool
  default     = true
}

variable "extra_labels" {
  description = "Additional labels applied to every resource that supports labels."
  type        = map(string)
  default     = {}
}
