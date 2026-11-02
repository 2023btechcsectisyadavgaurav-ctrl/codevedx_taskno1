provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  name = "${var.name_prefix}-${var.environment}"

  # Applied to every resource that supports labels - the GCP equivalent of a resource group tag set.
  labels = merge(
    {
      project     = "cloud-infrastructure-deployment"
      environment = var.environment
      managed-by  = "terraform"
    },
    var.extra_labels,
  )

  required_apis = [
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "storage.googleapis.com",
  ]
}

# ---------------------------------------------------------------------------
# Enable the Google APIs the stack needs
# ---------------------------------------------------------------------------
resource "google_project_service" "apis" {
  for_each = toset(local.required_apis)

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# ---------------------------------------------------------------------------
# Networking: custom VPC, subnet, Cloud NAT
# ---------------------------------------------------------------------------
module "network" {
  source = "./modules/network"

  name        = local.name
  region      = var.region
  subnet_cidr = var.subnet_cidr

  depends_on = [google_project_service.apis]
}

# ---------------------------------------------------------------------------
# Identity and firewall
# ---------------------------------------------------------------------------
module "security" {
  source = "./modules/security"

  name           = local.name
  project_id     = var.project_id
  network_name   = module.network.network_name
  subnet_cidr    = var.subnet_cidr
  enable_iap_ssh = var.enable_iap_ssh

  depends_on = [google_project_service.apis]
}

# ---------------------------------------------------------------------------
# Storage
# ---------------------------------------------------------------------------
module "storage" {
  source = "./modules/storage"

  name                = local.name
  project_id          = var.project_id
  region              = var.region
  force_destroy       = var.bucket_force_destroy
  labels              = local.labels
  reader_service_acct = module.security.service_account_email

  depends_on = [google_project_service.apis]
}

# ---------------------------------------------------------------------------
# Compute: instance template, regional MIG across zones, autoscaler, health check
# ---------------------------------------------------------------------------
module "compute" {
  source = "./modules/compute"

  name                  = local.name
  region                = var.region
  zones                 = var.zones
  subnetwork_self_link  = module.network.subnetwork_self_link
  service_account_email = module.security.service_account_email
  machine_type          = var.machine_type
  boot_disk_size_gb     = var.boot_disk_size_gb
  min_replicas          = var.min_replicas
  max_replicas          = var.max_replicas
  cpu_target            = var.cpu_target_utilization
  assets_bucket         = module.storage.bucket_name
  labels                = local.labels

  depends_on = [google_project_service.apis, module.network, module.security]
}

# ---------------------------------------------------------------------------
# Global HTTP load balancer in front of the MIG
# ---------------------------------------------------------------------------
module "loadbalancer" {
  source = "./modules/loadbalancer"

  name              = local.name
  instance_group    = module.compute.instance_group
  health_check_self = module.compute.health_check_id

  depends_on = [google_project_service.apis]
}
