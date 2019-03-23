output "alertmanager_slack_url" {
  value = "${var.alertmanager_slack_url}"
}
output "cloudflare_email" {
  value = "${var.cloudflare_email}"
}
output "cloudflare_token" {
  value = "${var.cloudflare_token}"
}
output "cluster_ingress_address" {
  value = "${module.devops.cluster_ingress_address}"
}
output "env_module_path" {
  value = "${module.devops.path}"
}
output "grafana_admin_password" {
  value = "${var.grafana_admin_password}"
}
output "grafana_db_root_password" {
  value = "${var.grafana_db_root_password}"
}
output "grafana_db_user_password" {
  value = "${var.grafana_db_user_password}"
}
output "letsencrypt_account_email" {
  value = "${var.devops_letsencrypt_account_email}"
}
output "letsencrypt_url" {
  value = "${var.devops_letsencrypt_url}"
}
output "kubewatch_slack_token" {
  value = "${var.devops_kubewatch_slack_token}"
}
output "whitelisted_cidrs" {
  value = "${var.devops_whitelisted_cidrs}"
}
