# Offline tests: the Google provider is mocked, so no GCP account or credentials are needed.
# Run with:  terraform init -backend=false && terraform test

mock_provider "google" {}

variables {
  project_id = "test-project"
}

run "default_plan_is_highly_available" {
  command = plan

  assert {
    condition     = length(output.zones) == 3
    error_message = "Web tier should be spread over three zones by default."
  }

  assert {
    condition     = output.autoscaling_range.min >= 2
    error_message = "Autoscaler minimum must be at least 2 so there is no single point of failure."
  }

  assert {
    condition     = output.autoscaling_range.max > output.autoscaling_range.min
    error_message = "Autoscaler must have headroom to scale out."
  }
}

run "default_plan_is_secure" {
  command = plan

  assert {
    condition     = output.security_posture.vm_has_public_ip == false
    error_message = "VMs must not have public IP addresses."
  }

  assert {
    condition     = output.security_posture.shielded_vm_enabled
    error_message = "Shielded VM (secure boot, vTPM, integrity monitoring) must be enabled."
  }

  assert {
    condition     = !contains(output.security_posture.allow_rule_sources, "0.0.0.0/0")
    error_message = "No allow rule may be open to the whole internet."
  }

  assert {
    condition     = output.security_posture.bucket_public_access == "enforced"
    error_message = "Bucket must enforce public access prevention."
  }

  assert {
    condition     = output.security_posture.bucket_uniform_access
    error_message = "Bucket must use uniform bucket-level access."
  }

  assert {
    condition     = output.security_posture.bucket_versioning
    error_message = "Bucket versioning must be enabled."
  }
}

run "iap_ssh_can_be_disabled" {
  command = plan

  variables {
    enable_iap_ssh = false
  }

  assert {
    condition     = !contains(output.security_posture.allow_rule_sources, "35.235.240.0/20")
    error_message = "IAP SSH range must not be allowed when enable_iap_ssh is false."
  }
}

run "rejects_single_zone" {
  command = plan

  variables {
    zones = ["us-central1-a"]
  }

  expect_failures = [var.zones]
}

run "rejects_single_replica" {
  command = plan

  variables {
    min_replicas = 1
  }

  expect_failures = [var.min_replicas]
}

run "rejects_max_below_min" {
  command = plan

  variables {
    min_replicas = 4
    max_replicas = 3
  }

  expect_failures = [var.max_replicas]
}

run "rejects_bad_environment" {
  command = plan

  variables {
    environment = "qa"
  }

  expect_failures = [var.environment]
}
