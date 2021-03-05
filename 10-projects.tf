data "google_organization" "kfirfamily" {
  domain = "kfirfamily.com"
}

resource "google_project" "project" {
  skip_delete = true
  project_id = "arikkfir"
  name = "arikkfir"
  org_id = data.google_organization.kfirfamily.org_id
  billing_account = var.billing_account
}

resource "google_project_service" "apis" {
  for_each = toset([
    "cloudbilling.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "dns.googleapis.com",
    "redis.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
    "stackdriver.googleapis.com",
  ])
  project = google_project.project.project_id
  service = each.key
  disable_dependent_services = false
  disable_on_destroy = false
}
