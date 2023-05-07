data "google_project" "arikkfir" {
  project_id = "arikkfir"
}

data "google_project" "arik-kfir" {
  project_id = "arik-kfir"
}

data "google_compute_default_service_account" "arik-kfir" {
  project = data.google_project.arik-kfir.project_id
}

data "google_compute_network" "default" {
  project = data.google_project.arik-kfir.project_id
  name    = "default"
}

resource "google_project_service" "apis" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerfilesystem.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "pubsub.googleapis.com",
    "secretmanager.googleapis.com",
    "servicemanagement.googleapis.com",
    "serviceusage.googleapis.com",
  ])
  project                    = data.google_project.arik-kfir.project_id
  service                    = each.key
  disable_dependent_services = false
  disable_on_destroy         = false
}

output "gcp_project_id" {
  value = data.google_project.arik-kfir.project_id
}

output "gcp_project_number" {
  value = data.google_project.arik-kfir.number
}
