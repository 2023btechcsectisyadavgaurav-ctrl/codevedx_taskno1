data "google_compute_image" "debian" {
  family  = "debian-12"
  project = "debian-cloud"
}

# ---------------------------------------------------------------------------
# Health check shared by the load balancer and by MIG auto-healing
# ---------------------------------------------------------------------------
resource "google_compute_health_check" "http" {
  name                = "${var.name}-http-hc"
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  http_health_check {
    port         = 80
    request_path = "/healthz"
  }
}

# ---------------------------------------------------------------------------
# Instance template: hardened VM with no public IP
# ---------------------------------------------------------------------------
resource "google_compute_instance_template" "web" {
  name_prefix  = "${var.name}-web-"
  region       = var.region
  machine_type = var.machine_type
  description  = "Nginx web server for ${var.name}"
  labels       = var.labels
  tags         = ["web"]

  disk {
    source_image = data.google_compute_image.debian.self_link
    boot         = true
    auto_delete  = true
    disk_type    = "pd-balanced"
    disk_size_gb = var.boot_disk_size_gb
    labels       = var.labels
  }

  # No access_config block => no external IP. Outbound traffic goes through Cloud NAT.
  network_interface {
    subnetwork = var.subnetwork_self_link
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  metadata = {
    enable-oslogin         = "TRUE"
    block-project-ssh-keys = "TRUE"
    assets-bucket          = var.assets_bucket
    startup-script         = file("${path.module}/startup.sh")
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------
# Regional managed instance group: instances are spread evenly across the zones
# ---------------------------------------------------------------------------
resource "google_compute_region_instance_group_manager" "web" {
  name                      = "${var.name}-web-mig"
  region                    = var.region
  base_instance_name        = "${var.name}-web"
  distribution_policy_zones = var.zones

  version {
    name              = "primary"
    instance_template = google_compute_instance_template.web.self_link_unique
  }

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.http.id
    initial_delay_sec = 180
  }

  # Rolling updates: replace instances one zone-width at a time so capacity never drops to zero.
  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    max_surge_fixed       = length(var.zones)
    max_unavailable_fixed = length(var.zones)
  }
}

# ---------------------------------------------------------------------------
# Autoscaler: scale on average CPU
# ---------------------------------------------------------------------------
resource "google_compute_region_autoscaler" "web" {
  name   = "${var.name}-web-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.web.id

  autoscaling_policy {
    min_replicas    = var.min_replicas
    max_replicas    = var.max_replicas
    cooldown_period = 90

    cpu_utilization {
      target = var.cpu_target
    }
  }
}
