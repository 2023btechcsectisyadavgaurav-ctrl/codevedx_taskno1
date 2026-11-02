resource "google_storage_bucket" "assets" {
  name          = "${var.name}-${var.project_id}-assets"
  project       = var.project_id
  location      = var.region
  storage_class = "STANDARD"
  force_destroy = var.force_destroy
  labels        = var.labels

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  # Keep storage costs bounded: drop old object versions after 30 days.
  lifecycle_rule {
    condition {
      days_since_noncurrent_time = 30
      with_state                 = "ARCHIVED"
    }
    action {
      type = "Delete"
    }
  }
}

# The web servers may read objects, nothing more.
resource "google_storage_bucket_iam_member" "vm_reader" {
  bucket = google_storage_bucket.assets.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${var.reader_service_acct}"
}
