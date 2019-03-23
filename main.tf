terraform {
  required_version = "~> 0.11.11"
  backend "gcs" {
    project = "arikkfir"
    bucket  = "arikkfir-terraform"
    prefix  = "global"
  }
}
resource "google_project" "arikkfir" {
  project_id      = "arikkfir"
  name            = "arikkfir"
  org_id          = "${var.gcp_org_id}"
  billing_account = "${var.gcp_billing_account_id}"
}
resource "google_project_service" "apis" {
  count                      = "${length(var.gcp_project_apis)}"
  provider                   = "google-beta"
  project                    = "arikkfir"
  service                    = "${var.gcp_project_apis[count.index]}"
  disable_dependent_services = false
  disable_on_destroy         = false
}
resource "cloudflare_zone" "kfirs" {
  zone = "kfirs.com"
  plan = "free"
}
resource "cloudflare_record" "kfirs-apex" {
  domain  = "${cloudflare_zone.kfirs.zone}"
  name    = "${cloudflare_zone.kfirs.zone}"
  type    = "CNAME"
  value   = "arikkfir.github.io"
  ttl     = 1
  proxied = true
}
resource "cloudflare_record" "kfirs-mx" {
  count    = "${length(var.kfirs-com-mx-records-values)}"
  domain   = "${cloudflare_zone.kfirs.zone}"
  name     = "${cloudflare_zone.kfirs.zone}"
  type     = "MX"
  value    = "${var.kfirs-com-mx-records-values[count.index]}"
  ttl      = 1
  priority = "${var.kfirs-com-mx-records-priorities[count.index]}"
  proxied  = false
}
resource "cloudflare_record" "kfirs-www" {
  domain  = "${cloudflare_zone.kfirs.zone}"
  name    = "www.${cloudflare_zone.kfirs.zone}"
  type    = "CNAME"
  value   = "arikkfir.github.io"
  ttl     = 1
  proxied = true
}
module "devops" {
  source              = "github.com/arikkfir/infrastructure-env?ref=master"
  name                = "devops"
  gcp_project_id      = "${google_project.arikkfir.name}"
  gke_master_password = "${var.devops_gke_master_password}"
  gke_master_username = "${var.devops_gke_master_username}"
  gke_master_version  = "${var.devops_gke_master_version}"
  gke_node_version    = "${var.devops_gke_node_version}"
  whitelisted_cidrs   = "${var.devops_whitelisted_cidrs}"
}
resource "cloudflare_record" "jenkins" {
  domain  = "${cloudflare_zone.kfirs.zone}"
  name    = "jenkins.${cloudflare_zone.kfirs.zone}"
  type    = "CNAME"
  value   = "${module.devops.cluster_dns_name}"
  ttl     = 1
  proxied = false
}
resource "cloudflare_record" "spinnaker_deck" {
  domain  = "${cloudflare_zone.kfirs.zone}"
  name    = "spinnaker.${cloudflare_zone.kfirs.zone}"
  type    = "CNAME"
  value   = "${module.devops.cluster_dns_name}"
  ttl     = 1
  proxied = false
}
resource "cloudflare_record" "spinnaker_gate" {
  domain  = "${cloudflare_zone.kfirs.zone}"
  name    = "gate.spinnaker.${cloudflare_zone.kfirs.zone}"
  type    = "CNAME"
  value   = "${module.devops.cluster_dns_name}"
  ttl     = 1
  proxied = false
}
