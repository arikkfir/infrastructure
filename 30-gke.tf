resource "google_compute_network" "gke" {
  depends_on = [
    google_project_service.apis
  ]
  project = google_project.project.project_id
  name = "gke"
  description = "GKE VPC"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke_subnet_europe_west3" {
  project = google_project.project.project_id
  name = "gke-subnet-europe-west3"
  network = google_compute_network.gke.id
  region = "europe-west3"
  ip_cidr_range = "10.110.0.0/16"
  secondary_ip_range {
    range_name = "gke-primary-cluster-pods"
    ip_cidr_range = "10.120.0.0/16"
  }
  secondary_ip_range {
    range_name = "gke-primary-cluster-services"
    ip_cidr_range = "10.130.0.0/16"
  }
}

resource "google_service_account" "kubernetes" {
  project = google_project.project.project_id
  account_id = "kubernetes"
  display_name = "Kubernetes nodes service account"
}

resource "google_project_iam_member" "kubernetes_log_writer" {
  project = google_project.project.project_id
  role = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.kubernetes.email}"
}

resource "google_project_iam_member" "kubernetes_metrics_writer" {
  project = google_project.project.project_id
  role = "roles/monitoring.metricWriter"
  member = "serviceAccount:${google_service_account.kubernetes.email}"
}

resource "google_compute_address" "gke_ingress" {
  depends_on = [
    google_project_service.apis
  ]
  project = google_project.project.project_id
  name = "gke-ingress"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
  region = var.gcp_region
  description = "GKE Ingress"
}

resource "google_container_cluster" "primary" {
  provider = google-beta
  project = google_project.project.project_id
  name = "primary"
  description = "Primary"
  location = var.gcp_zone
  initial_node_count = 1
  remove_default_node_pool = true
  release_channel {
    channel = "RAPID"
  }
  networking_mode = "VPC_NATIVE"
  network = google_compute_network.gke.self_link
  subnetwork = google_compute_subnetwork.gke_subnet_europe_west3.self_link
  ip_allocation_policy {
    cluster_secondary_range_name = "gke-primary-cluster-pods"
    services_secondary_range_name = "gke-primary-cluster-services"
  }
  addons_config {
    http_load_balancing {
      disabled = true
    }
    config_connector_config {
      enabled = true
    }
  }
  authenticator_groups_config {
    security_group = "gke-security-groups@kfirfamily.com"
  }
  workload_identity_config {
    identity_namespace = "${google_project.project.project_id}.svc.id.goog"
  }
  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }
  cluster_telemetry {
    type = "ENABLED"
  }
  vertical_pod_autoscaling {
    enabled = false
  }
}

resource "google_container_node_pool" "n2-standard-8" {
  project = google_container_cluster.primary.project
  cluster = google_container_cluster.primary.name
  name = "n2-standard-8"
  location = var.gcp_zone
  initial_node_count = 1
  autoscaling {
    min_node_count = 0
    max_node_count = 4
  }
  management {
    auto_repair = true
    auto_upgrade = true
  }
  node_config {
    machine_type = "n2-standard-8"
    preemptible = true
    disk_size_gb = 100
    disk_type = "pd-standard"
    service_account = google_service_account.kubernetes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }
  }
  upgrade_settings {
    max_surge = 1
    max_unavailable = 0
  }
}
