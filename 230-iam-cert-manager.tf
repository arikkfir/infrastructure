resource "google_service_account" "cert-manager" {
  project      = data.google_project.arik-kfir.project_id
  account_id   = "cert-manager"
  display_name = "cert-manager"
  description  = "Used by the cert-manager in GKE cluster to update DNS records."
}

resource "google_service_account_iam_member" "cert-manager_workload_identity" {
  service_account_id = google_service_account.cert-manager.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${data.google_project.arik-kfir.project_id}.svc.id.goog[cert-manager/cert-manager]"
}

resource "google_service_account_iam_member" "cert-manager-cainjector_workload_identity" {
  service_account_id = google_service_account.cert-manager.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${data.google_project.arik-kfir.project_id}.svc.id.goog[cert-manager/cert-manager-cainjector]"
}

resource "google_service_account_iam_member" "cert-manager-webhook_workload_identity" {
  service_account_id = google_service_account.cert-manager.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${data.google_project.arik-kfir.project_id}.svc.id.goog[cert-manager/cert-manager-webhook]"
}

resource "google_project_iam_member" "cert-manager" {
  for_each = toset([
    "roles/dns.admin",
  ])
  project = data.google_project.arik-kfir.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.cert-manager.email}"
}
