resource "google_service_account" "infrastructure" {
  project      = data.google_project.arik-kfir.project_id
  account_id   = "infrastructure"
  display_name = "GitHub Actions: arik-kfir/infrastructure"
  description  = "Used by the arik-kfir/infrastructure GitHub Actions workflows."
}

resource "google_service_account_iam_member" "infrastructure-workload-identity-user" {
  service_account_id = google_service_account.infrastructure.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.arik-kfir-github-actions.name}/attribute.repository/arik-kfir/infrastructure"
}

resource "google_organization_iam_member" "infrastructure" {
  for_each = toset([
    "roles/iam.organizationRoleViewer",
    "roles/resourcemanager.organizationViewer",
  ])
  org_id = data.google_organization.kfirfamily.org_id
  role   = each.key
  member = "serviceAccount:${google_service_account.infrastructure.email}"
}

resource "google_project_iam_member" "infrastructure" {
  for_each = toset([
    "roles/compute.networkAdmin",
    "roles/compute.viewer",
    "roles/container.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.workloadIdentityPoolAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/storage.admin",
  ])
  project = data.google_project.arik-kfir.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.infrastructure.email}"
}

resource "google_storage_bucket_iam_member" "arik-kfir-terraform-infrastructure-objectAdmin" {
  bucket = data.google_storage_bucket.arik-kfir-terraform.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.infrastructure.email}"
}

# Enable the infrastructure SA access to the default compute service account
# This is required to create GKE clusters, and avoid the following error:
#   -> Error: googleapi: Error 400: The user does not have access to service account "...". Ask a project owner to grant you the iam.serviceAccountUser role on the service account., badRequest
resource "google_service_account_iam_member" "default-compute-infrastructure-iam-serviceAccountUser" {
  service_account_id = data.google_compute_default_service_account.arik-kfir.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.infrastructure.email}"
}
