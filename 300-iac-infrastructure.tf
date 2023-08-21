resource "google_service_account" "infrastructure" {
  account_id   = "infrastructure"
  display_name = "GitHub Actions: arikkfir/infrastructure"
  description  = "GitHub Actions workflows in arikkfir/infrastructure repository."
}

resource "google_service_account_iam_member" "infrastructure_workload-identity-user" {
  service_account_id = google_service_account.infrastructure.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github-actions.name}/attribute.repository/arikkfir/infrastructure"
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
    "roles/owner",
  ])
  project = data.google_project.default.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.infrastructure.email}"
}

resource "google_storage_bucket_iam_member" "arikkfir-devops_infrastructure" {
  for_each = toset([
    "roles/storage.admin",
    "roles/storage.objectAdmin",
  ])
  bucket = data.google_storage_bucket.arikkfir-devops.name
  role    = each.key
  member = "serviceAccount:${google_service_account.infrastructure.email}"
}

# Enable the infrastructure SA access to the default compute service account
# This is required to create GKE clusters, and avoid the following error:
#   -> Error: googleapi: Error 400: The user does not have access to service account "...". Ask a project owner to grant you the iam.serviceAccountUser role on the service account., badRequest
resource "google_service_account_iam_member" "compute-default-service-account_infrastructure_iam-serviceAccountUser" {
  service_account_id = data.google_compute_default_service_account.default.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.infrastructure.email}"
}
