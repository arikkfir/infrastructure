resource "google_service_account" "flux-notification-controller" {
  project      = data.google_project.arik-kfir.project_id
  account_id   = "flux-notification-controller"
  display_name = "flux-notification-controller"
  description  = "Used by FluxCD notification controller."
}

resource "google_service_account_iam_member" "flux-notification-controller_workload_identity" {
  service_account_id = google_service_account.flux-notification-controller.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${data.google_project.arik-kfir.project_id}.svc.id.goog[flux-system/notification-controller]"
}

resource "google_project_iam_member" "arik-kfir_flux-notification-controller" {
  for_each = toset([
    "roles/secretmanager.secretAccessor",
    "roles/secretmanager.viewer",
  ])
  project = data.google_project.arik-kfir.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.flux-notification-controller.email}"
}
