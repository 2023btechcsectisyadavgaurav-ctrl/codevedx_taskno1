variable "name" {
  description = "Name prefix for the bucket."
  type        = string
}

variable "project_id" {
  description = "Project that owns the bucket (also keeps the name globally unique)."
  type        = string
}

variable "region" {
  description = "Bucket location."
  type        = string
}

variable "force_destroy" {
  description = "Delete the bucket even when it contains objects."
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels applied to the bucket."
  type        = map(string)
  default     = {}
}

variable "reader_service_acct" {
  description = "Service account email granted read-only access to the bucket."
  type        = string
}
