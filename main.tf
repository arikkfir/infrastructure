terraform {
  required_version = "~> 0.11.13"
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
resource "google_compute_network" "devops" {
  provider                = "google-beta"
  project                 = "${google_project.arikkfir.project_id}"
  name                    = "devops"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "devops" {
  provider           = "google-beta"
  project            = "${google_project.arikkfir.project_id}"
  name               = "europe-west1"
  ip_cidr_range      = "10.128.0.0/16"
  region             = "europe-west1"
  network            = "${google_compute_network.devops.self_link}"
  secondary_ip_range = [
    {
      ip_cidr_range = "10.130.0.0/16"
      range_name    = "gke-pods"
    },
    {
      ip_cidr_range = "10.131.0.0/16"
      range_name    = "gke-services"
    }
  ]
}
resource "google_compute_address" "devops_cluster_ingress" {
  provider     = "google-beta"
  project      = "${google_project.arikkfir.project_id}"
  name         = "gke-devops-lb"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
  region       = "europe-west1"
}
resource "google_container_cluster" "devops" {
  provider                    = "google-beta"
  project                     = "${google_project.arikkfir.project_id}"
  name                        = "devops"
  zone                        = "europe-west1-b"
  enable_binary_authorization = false
  enable_kubernetes_alpha     = false
  enable_tpu                  = false
  enable_legacy_abac          = false
  min_master_version          = "${var.devops_gke_master_version}"
  network                     = "${google_compute_network.devops.self_link}"
  subnetwork                  = "${google_compute_subnetwork.devops.self_link}"
  logging_service             = "logging.googleapis.com/kubernetes"
  monitoring_service          = "monitoring.googleapis.com/kubernetes"
  initial_node_count          = 1
  remove_default_node_pool    = true
  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }
    http_load_balancing {
      disabled = true
    }
    kubernetes_dashboard {
      disabled = true
    }
    network_policy_config {
      disabled = true
    }
  }
  cluster_autoscaling {
    enabled = false
  }
  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods"
    services_secondary_range_name = "gke-services"
  }
  maintenance_policy {
    "daily_maintenance_window" {
      start_time = "04:00"
    }
  }
  master_auth {
    username = "${var.devops_gke_master_username}"
    password = "${var.devops_gke_master_password}"
    client_certificate_config {
      issue_client_certificate = false
    }
  }
  network_policy {
    enabled = false
  }
  pod_security_policy_config {
    enabled = false
  }
}
resource "google_container_node_pool" "devops_core" {
  provider           = "google-beta"
  project            = "${google_project.arikkfir.project_id}"
  name               = "core-1"
  zone               = "${google_container_cluster.devops.zone}"
  cluster            = "${google_container_cluster.devops.name}"
  version            = "${var.devops_gke_node_version}"
  initial_node_count = 1
  autoscaling {
    max_node_count = 3
    min_node_count = 1
  }
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  node_config {
    min_cpu_platform = "Automatic"
    disk_size_gb     = 100
    disk_type        = "pd-standard"
    machine_type     = "n1-standard-2"
    preemptible      = true
    metadata {
      "disable-legacy-endpoints" = "true"
    }
  }
}
resource "cloudflare_record" "cluster" {
  domain  = "kfirs.com"
  name    = "cluster.devops.kfirs.com"
  type    = "A"
  value   = "${google_compute_address.devops_cluster_ingress.address}"
  ttl     = 1
  proxied = false
}
resource "cloudflare_record" "jenkins" {
  domain  = "${cloudflare_zone.kfirs.zone}"
  name    = "jenkins.${cloudflare_zone.kfirs.zone}"
  type    = "CNAME"
  value   = "${cloudflare_record.cluster.name}"
  ttl     = 1
  proxied = false
}
resource "cloudflare_record" "spinnaker_deck" {
  domain  = "${cloudflare_zone.kfirs.zone}"
  name    = "spinnaker.${cloudflare_zone.kfirs.zone}"
  type    = "CNAME"
  value   = "${cloudflare_record.cluster.name}"
  ttl     = 1
  proxied = false
}
resource "cloudflare_record" "spinnaker_gate" {
  domain  = "${cloudflare_zone.kfirs.zone}"
  name    = "gate.spinnaker.${cloudflare_zone.kfirs.zone}"
  type    = "CNAME"
  value   = "${cloudflare_record.cluster.name}"
  ttl     = 1
  proxied = false
}
resource "cloudflare_record" "traefik" {
  domain  = "kfirs.com"
  name    = "traefik.devops.kfirs.com"
  type    = "CNAME"
  value   = "${cloudflare_record.cluster.name}"
  ttl     = 1
  proxied = false
}
