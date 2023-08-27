resource "google_service_account" "delivery" {
  account_id   = "delivery"
  display_name = "GitHub Actions: arikkfir/delivery"
  description  = "GitHub Actions workflows in arikkfir/delivery repository."
}

# Allow this service account to connect from workflows in the infrastructure repository
resource "google_service_account_iam_member" "delivery_infrastructure_workload-identity-user" {
  service_account_id = google_service_account.delivery.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github-actions.name}/attribute.repository/arikkfir/infrastructure"
}

resource "google_service_account_iam_member" "delivery_workload-identity-user" {
  service_account_id = google_service_account.delivery.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github-actions.name}/attribute.repository/arikkfir/delivery"
}

resource "google_organization_iam_member" "delivery" {
  for_each = toset([
    "roles/iam.organizationRoleViewer",
    "roles/resourcemanager.organizationViewer",
  ])
  org_id = data.google_organization.kfirfamily.org_id
  role   = each.key
  member = "serviceAccount:${google_service_account.delivery.email}"
}

resource "google_project_iam_member" "delivery" {
  for_each = toset([
    "roles/container.clusterViewer",
    "roles/container.developer",
  ])
  project = data.google_project.default.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.delivery.email}"
}
