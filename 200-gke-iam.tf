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
