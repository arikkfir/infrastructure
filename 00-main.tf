terraform {
  required_version = ">=0.14.5"
  backend "gcs" {
    project = "arikkfir"
    bucket  = "arikkfir-terraform"
    prefix  = "global"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.56.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 3.57.0"
    }
  }
}

variable "billing_account" {
  type = string
  description = "Billing account ID"
  default = "015391-BCAAAB-11556B"
}

variable "gcp_region" {
  type = string
  default = "europe-west3"
  description = "Region to place compute resources."
}

variable "gcp_zone" {
  type = string
  default = "europe-west3-a"
  description = "Zone to place compute resources."
}

# ----------------------------------------

//resource "cloudflare_zone" "kfirs" {
//  zone = "kfirs.com"
//  plan = "free"
//}
//resource "cloudflare_record" "kfirs-apex" {
//  domain  = "${cloudflare_zone.kfirs.zone}"
//  name    = "${cloudflare_zone.kfirs.zone}"
//  type    = "CNAME"
//  value   = "arikkfir.github.io"
//  ttl     = 1
//  proxied = true
//}
//resource "cloudflare_record" "kfirs-mx" {
//  count    = "${length(var.kfirs-com-mx-records-values)}"
//  domain   = "${cloudflare_zone.kfirs.zone}"
//  name     = "${cloudflare_zone.kfirs.zone}"
//  type     = "MX"
//  value    = "${var.kfirs-com-mx-records-values[count.index]}"
//  ttl      = 1
//  priority = "${var.kfirs-com-mx-records-priorities[count.index]}"
//  proxied  = false
//}
//resource "cloudflare_record" "kfirs-www" {
//  domain  = "${cloudflare_zone.kfirs.zone}"
//  name    = "www.${cloudflare_zone.kfirs.zone}"
//  type    = "CNAME"
//  value   = "arikkfir.github.io"
//  ttl     = 1
//  proxied = true
//}
//resource "cloudflare_record" "cluster" {
//  domain  = "kfirs.com"
//  name    = "cluster.devops.kfirs.com"
//  type    = "A"
//  value   = "${google_compute_address.devops_cluster_ingress.address}"
//  ttl     = 1
//  proxied = false
//}
//resource "cloudflare_record" "jenkins" {
//  domain  = "${cloudflare_zone.kfirs.zone}"
//  name    = "jenkins.${cloudflare_zone.kfirs.zone}"
//  type    = "CNAME"
//  value   = "${cloudflare_record.cluster.name}"
//  ttl     = 1
//  proxied = false
//}
//resource "cloudflare_record" "spinnaker_deck" {
//  domain  = "${cloudflare_zone.kfirs.zone}"
//  name    = "spinnaker.${cloudflare_zone.kfirs.zone}"
//  type    = "CNAME"
//  value   = "${cloudflare_record.cluster.name}"
//  ttl     = 1
//  proxied = false
//}
//resource "cloudflare_record" "spinnaker_gate" {
//  domain  = "${cloudflare_zone.kfirs.zone}"
//  name    = "gate.spinnaker.${cloudflare_zone.kfirs.zone}"
//  type    = "CNAME"
//  value   = "${cloudflare_record.cluster.name}"
//  ttl     = 1
//  proxied = false
//}
//resource "cloudflare_record" "traefik" {
//  domain  = "kfirs.com"
//  name    = "traefik.devops.kfirs.com"
//  type    = "CNAME"
//  value   = "${cloudflare_record.cluster.name}"
//  ttl     = 1
//  proxied = false
//}
