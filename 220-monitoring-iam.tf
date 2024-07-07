resource "google_service_account" "otel" {
  account_id   = "otel-collector"
  display_name = "OpenTelemetry Collector"
  description  = "OTEL collectors reporting metrics, traces and logs to GCP."
}

resource "google_service_account_iam_member" "otel-agent_workload-identity" {
  service_account_id = google_service_account.otel.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${data.google_project.default.project_id}.svc.id.goog[monitoring/otel-agent]"
}

resource "google_service_account_iam_member" "otel-gateway_workload-identity" {
  service_account_id = google_service_account.otel.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${data.google_project.default.project_id}.svc.id.goog[monitoring/otel-gateway]"
}

resource "google_project_iam_member" "otel" {
  for_each = toset([
    "roles/monitoring.metricWriter",
    "roles/cloudtrace.agent",
    "roles/logging.logWriter",
  ])
  project = data.google_project.default.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.otel.email}"
}
