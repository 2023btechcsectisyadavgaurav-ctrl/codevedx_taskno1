# ---------------------------------------------------------------------------
# Identity: dedicated least-privilege service account for the web servers
# (instead of the default Compute Engine account, which has Editor on the project)
# ---------------------------------------------------------------------------
resource "google_service_account" "vm" {
  account_id   = "${var.name}-vm"
  display_name = "Web server service account (${var.name})"
}

resource "google_project_iam_member" "vm_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.vm.email}"
}

# ---------------------------------------------------------------------------
# Firewall: default-deny ingress, then open only what is needed.
# Rules target the service account, not network tags, so only these VMs are affected.
# ---------------------------------------------------------------------------
locals {
  # Google Front Ends / health checkers (documented, fixed ranges).
  google_lb_ranges = ["130.211.0.0/22", "35.191.0.0/16"]

  # Identity-Aware Proxy TCP forwarding range.
  iap_range = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "allow_lb_http" {
  name          = "${var.name}-allow-lb-http"
  network       = var.network_name
  description   = "Allow HTTP from the Google load balancer and health checkers only"
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = local.google_lb_ranges

  target_service_accounts = [google_service_account.vm.email]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow_iap_ssh" {
  count = var.enable_iap_ssh ? 1 : 0

  name          = "${var.name}-allow-iap-ssh"
  network       = var.network_name
  description   = "Allow SSH only via Identity-Aware Proxy (gcloud compute ssh --tunnel-through-iap)"
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = local.iap_range

  target_service_accounts = [google_service_account.vm.email]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow_internal" {
  name          = "${var.name}-allow-internal"
  network       = var.network_name
  description   = "Allow traffic between instances inside the subnet"
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = [var.subnet_cidr]

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "deny_all_ingress" {
  name          = "${var.name}-deny-all-ingress"
  network       = var.network_name
  description   = "Explicit low-priority default deny so blocked traffic is logged"
  direction     = "INGRESS"
  priority      = 65000
  source_ranges = ["0.0.0.0/0"]

  deny {
    protocol = "all"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
