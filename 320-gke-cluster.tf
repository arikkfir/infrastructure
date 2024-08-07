resource "google_container_cluster" "main" {
  depends_on = [
    google_project_service.apis,
    google_project_iam_member.gke-node,
    google_project_iam_member.config-connector,
    google_service_account_iam_member.config-connector_workload_identity,
  ]

  # GENERAL
  ######################################################################################################################
  provider            = google-beta
  name                = "main"
  location            = local.gcp_zone_a
  description         = "Main cluster."
  deletion_protection = false

  # NODE CONFIGURATION
  ######################################################################################################################
  initial_node_count       = 1
  remove_default_node_pool = true
  cluster_autoscaling {
    autoscaling_profile = "OPTIMIZE_UTILIZATION"
  }

  # STORAGE
  ######################################################################################################################
  addons_config {
    gcs_fuse_csi_driver_config {
      enabled = true
    }
  }

  # NETWORKING
  ######################################################################################################################
  network         = google_compute_network.default.self_link
  subnetwork      = google_compute_subnetwork.gke.self_link
  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    services_secondary_range_name = google_compute_subnetwork.gke.secondary_ip_range.0.range_name
    cluster_secondary_range_name  = google_compute_subnetwork.gke.secondary_ip_range.1.range_name
  }
  dns_config {
    cluster_dns       = "CLOUD_DNS"
    cluster_dns_scope = "DNS_SCOPE_UNSPECIFIED"
  }
  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }

  # OPERATIONS
  ######################################################################################################################
  release_channel {
    channel = "STABLE"
  }
  logging_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "APISERVER",
      "CONTROLLER_MANAGER",
      "SCHEDULER",
      "WORKLOADS"
    ]
  }
  monitoring_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "APISERVER",
      "SCHEDULER",
      "CONTROLLER_MANAGER",
      "STORAGE",
      "HPA",
      "POD",
      "DAEMONSET",
      "DEPLOYMENT",
      "STATEFULSET"
    ]
    managed_prometheus {
      enabled = true
    }
  }
  maintenance_policy {
    daily_maintenance_window {
      start_time = "02:00"
    }
  }

  # SECURITY
  ######################################################################################################################
  authenticator_groups_config {
    security_group = "gke-security-groups@${data.google_organization.kfirfamily.domain}"
  }
  workload_identity_config {
    workload_pool = "${data.google_project.default.project_id}.svc.id.goog"
  }

  # TERRAFORM HOOKS
  ######################################################################################################################
  lifecycle {
    ignore_changes = [dns_config.0.cluster_dns_scope]
  }
}
