variable "alertmanager_slack_url" {
  description = "Slack URL for the Prometheus Alertmanager bot."
}
variable "cloudflare_email" {
  description = "Email of the Cloudflare account hosting the kfirs.com zone."
}
variable "cloudflare_token" {
  description = "Access token of the Cloudflare account hosting the kfirs.com zone."
}
variable "devops_gke_master_password" {}
variable "devops_gke_master_username" {}
variable "devops_gke_master_version" {}
variable "devops_gke_node_version" {}
variable "devops_letsencrypt_account_email" {
  description = "Email of the Let's Encrypt account to use for generating TLS certificates."
}
variable "devops_letsencrypt_url" {
  description = "The URL for the Let's Encrypt service to use for generating TLS certificates."
}
variable "devops_kubewatch_slack_token" {
  description = "Slack token used for the Kubewatch bot."
}
variable "devops_whitelisted_cidrs" {
  type = "list"
}
variable "gcp_billing_account_id" {}
variable "gcp_org_id" {}
variable "gcp_project_apis" {
  type = "list"
}
variable "grafana_admin_password" {}
variable "grafana_db_root_password" {}
variable "grafana_db_user_password" {}
variable "kfirs-com-mx-records-priorities" {
  type = "list"
}
variable "kfirs-com-mx-records-values" {
  type = "list"
}
