output "instance_group" {
  description = "Instance group URL, used as the load balancer backend."
  value       = google_compute_region_instance_group_manager.web.instance_group
}

output "instance_group_manager_name" {
  description = "Name of the managed instance group."
  value       = google_compute_region_instance_group_manager.web.name
}

output "health_check_id" {
  description = "ID of the HTTP health check."
  value       = google_compute_health_check.http.id
}

output "distribution_zones" {
  description = "Zones used by the managed instance group."
  value       = sort(tolist(google_compute_region_instance_group_manager.web.distribution_policy_zones))
}

output "min_replicas" {
  description = "Autoscaler minimum."
  value       = google_compute_region_autoscaler.web.autoscaling_policy[0].min_replicas
}

output "max_replicas" {
  description = "Autoscaler maximum."
  value       = google_compute_region_autoscaler.web.autoscaling_policy[0].max_replicas
}

output "has_public_ip" {
  description = "True if the instance template gives VMs an external IP."
  value       = length(google_compute_instance_template.web.network_interface[0].access_config) > 0
}

output "shielded_vm_enabled" {
  description = "True if secure boot, vTPM and integrity monitoring are all on."
  value = alltrue([
    google_compute_instance_template.web.shielded_instance_config[0].enable_secure_boot,
    google_compute_instance_template.web.shielded_instance_config[0].enable_vtpm,
    google_compute_instance_template.web.shielded_instance_config[0].enable_integrity_monitoring,
  ])
}
