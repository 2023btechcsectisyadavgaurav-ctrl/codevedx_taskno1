variable "name" {
  description = "Name prefix for load balancer resources."
  type        = string
}

variable "instance_group" {
  description = "Instance group URL used as the backend."
  type        = string
}

variable "health_check_self" {
  description = "ID of the health check attached to the backend service."
  type        = string
}
