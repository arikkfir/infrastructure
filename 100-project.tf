data "google_organization" "kfirfamily" {
  domain = "kfirfamily.com"
}

data "google_project" "default" {
  project_id = var.gcp_project_id
}

data "google_storage_bucket" "arikkfir-devops" {
  provider = google
  name     = "arikkfir-devops"
}

data "google_compute_default_service_account" "default" {}

resource "google_project_service" "apis" {
  for_each = toset([
    "artifactregistry.googleapis.com",
    "autoscaling.googleapis.com",
    "bigquery.googleapis.com",
    "bigquerymigration.googleapis.com",
    "bigquerystorage.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerfilesystem.googleapis.com",
    "containerregistry.googleapis.com",
    "containersecurity.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "oslogin.googleapis.com",
    "pubsub.googleapis.com",
    "secretmanager.googleapis.com",
    "servicemanagement.googleapis.com",
    "serviceusage.googleapis.com",
    "sheets.googleapis.com",
    "storage-api.googleapis.com",
    "storage-component.googleapis.com",
  ])
  service = each.key
}

resource "google_iam_workload_identity_pool" "github-actions" {
  workload_identity_pool_id = "github-actions"
  display_name              = "GitHub Actions"
  description               = "Identity pool for GitHub Actions workflows."
}

resource "google_iam_workload_identity_pool_provider" "github-oidc" {
  project                            = google_iam_workload_identity_pool.github-actions.project
  workload_identity_pool_id          = google_iam_workload_identity_pool.github-actions.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-oidc"
  description                        = "OIDC identity pool provider for GitHub Actions workflows."
  display_name                       = "GitHub OIDC"

  attribute_mapping = {
    "attribute.aud"              = "assertion.aud"
    "attribute.actor"            = "assertion.actor"
    "google.subject"             = "assertion.sub"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
    "attribute.ref_type"         = "assertion.ref_type"
    "attribute.ref"              = "assertion.ref"
    "attribute.event_name"       = "assertion.event_name"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}
