resource "google_service_account" "gke-node" {
  account_id   = "gke-node"
  display_name = "GKE Node"
  description  = "Service account used by GKE nodes"
}

resource "google_project_iam_member" "gke-node" {
  for_each = toset([
    "roles/container.defaultNodeServiceAccount",
    "roles/container.nodeServiceAgent",
    "roles/container.serviceAgent",
  ])
  project = data.google_project.default.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke-node.email}"
}

resource "google_service_account" "config-connector" {
  account_id   = "config-connector"
  display_name = "GKE Config Connector"
  description  = "Used to enact changes in the GCP project on behalf of the GKE config-connector service."
}

resource "google_service_account_iam_member" "config-connector_workload_identity" {
  service_account_id = google_service_account.config-connector.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${data.google_project.default.project_id}.svc.id.goog[cnrm-system/cnrm-controller-manager]"
}

resource "google_project_iam_member" "config-connector" {
  for_each = toset([
    "roles/owner",
  ])
  project = data.google_project.default.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.config-connector.email}"
}

output "config-connector-service-account-email" {
  value = google_service_account.config-connector.email
}
