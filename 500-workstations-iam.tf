resource "google_service_account" "workstation" {
  project      = data.google_project.default.project_id
  account_id   = "workstation"
  display_name = "Cloud Workstations"
  description  = "Used by Cloud Workstations VMs."
}

resource "google_project_iam_member" "workstation" {
  for_each = toset([
    "roles/owner",
  ])
  project = data.google_project.default.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.workstation.email}"
}
