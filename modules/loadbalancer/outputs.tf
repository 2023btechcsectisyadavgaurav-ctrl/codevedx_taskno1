output "ip_address" {
  description = "Public IP of the load balancer."
  value       = google_compute_global_address.lb.address
}
