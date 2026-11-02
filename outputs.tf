output "load_balancer_ip" {
  description = "Public IP address of the global HTTP load balancer."
  value       = module.loadbalancer.ip_address
}

output "application_url" {
  description = "URL to open in a browser once the instances are healthy (allow ~3-5 minutes after apply)."
  value       = "http://${module.loadbalancer.ip_address}"
}

output "network_name" {
  description = "Name of the VPC network."
  value       = module.network.network_name
}

output "subnet_cidr" {
  description = "CIDR of the application subnet."
  value       = var.subnet_cidr
}

output "instance_group_manager" {
  description = "Name of the regional managed instance group."
  value       = module.compute.instance_group_manager_name
}

output "zones" {
  description = "Zones the web tier is distributed across."
  value       = module.compute.distribution_zones
}

output "autoscaling_range" {
  description = "Minimum and maximum number of web servers."
  value = {
    min = module.compute.min_replicas
    max = module.compute.max_replicas
  }
}

output "service_account_email" {
  description = "Least-privilege service account attached to the web servers."
  value       = module.security.service_account_email
}

output "assets_bucket" {
  description = "Cloud Storage bucket for application assets."
  value       = module.storage.bucket_name
}

# Exposed so the automated tests (tests/*.tftest.hcl) can assert on the security posture at plan time.
output "security_posture" {
  description = "Security-relevant settings, asserted by the test suite."
  value = {
    vm_has_public_ip      = module.compute.has_public_ip
    shielded_vm_enabled   = module.compute.shielded_vm_enabled
    allow_rule_sources    = module.security.allow_rule_source_ranges
    bucket_public_access  = module.storage.public_access_prevention
    bucket_uniform_access = module.storage.uniform_bucket_level_access
    bucket_versioning     = module.storage.versioning_enabled
  }
}
