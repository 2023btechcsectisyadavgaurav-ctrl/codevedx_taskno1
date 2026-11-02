output "bucket_name" {
  description = "Name of the assets bucket."
  value       = google_storage_bucket.assets.name
}

output "public_access_prevention" {
  description = "Public access prevention setting."
  value       = google_storage_bucket.assets.public_access_prevention
}

output "uniform_bucket_level_access" {
  description = "Whether uniform bucket-level access is on."
  value       = google_storage_bucket.assets.uniform_bucket_level_access
}

output "versioning_enabled" {
  description = "Whether object versioning is on."
  value       = google_storage_bucket.assets.versioning[0].enabled
}
