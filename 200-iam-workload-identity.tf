resource "google_iam_workload_identity_pool" "arik-kfir-github-actions" {
  project                   = data.google_project.arik-kfir.project_id
  workload_identity_pool_id = "github-actions"
  display_name              = "GitHub Actions"
  description               = "Identity pool for GitHub Actions workflows."
}

resource "google_iam_workload_identity_pool_provider" "arik-kfir-default" {
  project                            = data.google_project.arik-kfir.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.arik-kfir-github-actions.workload_identity_pool_id
  workload_identity_pool_provider_id = "default"
  description                        = "OIDC identity pool provider for GitHub Actions workflows."
  display_name                       = "Default"
  attribute_mapping = {
    "attribute.aud"        = "assertion.aud"
    "attribute.actor"      = "assertion.actor"
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.ref_type"   = "assertion.ref_type"
    "attribute.ref"        = "assertion.ref"
    "attribute.event_name" = "assertion.event_name"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}
