output "service_account_email" {
  description = "Email of the web server service account."
  value       = google_service_account.vm.email
}

output "allow_rule_source_ranges" {
  description = "Source ranges of every internet-facing allow rule (used by tests to prove nothing is open to 0.0.0.0/0)."
  value = sort(distinct(concat(
    tolist(google_compute_firewall.allow_lb_http.source_ranges),
    var.enable_iap_ssh ? tolist(google_compute_firewall.allow_iap_ssh[0].source_ranges) : [],
  )))
}
