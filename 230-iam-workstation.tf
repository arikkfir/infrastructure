resource "google_service_account" "workstation" {
  project      = data.google_project.arik-kfir.project_id
  account_id   = "workstation"
  display_name = "Cloud Workstations"
  description  = "Used by Cloud Workstations VMs."
}

resource "google_project_iam_member" "arik-kfir_workstation" {
  for_each = toset([
    "roles/owner",
  ])
  project = data.google_project.arik-kfir.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.workstation.email}"
}
