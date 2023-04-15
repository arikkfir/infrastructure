resource "google_service_account" "delivery" {
  project      = data.google_project.arik-kfir.project_id
  account_id   = "delivery"
  display_name = "GitHub Actions: arik-kfir/delivery"
  description  = "Used by the arik-kfir/delivery GitHub Actions workflows."
}

resource "google_service_account_iam_member" "delivery-workload-identity-user" {
  service_account_id = google_service_account.delivery.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.arik-kfir-github-actions.name}/attribute.repository/arik-kfir/delivery"
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
  project = data.google_project.arik-kfir.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.delivery.email}"
}
