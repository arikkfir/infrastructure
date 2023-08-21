resource "google_container_cluster" "main" {
  depends_on = [
    google_project_service.apis,
    google_service_account_iam_member.compute-default-service-account_infrastructure_iam-serviceAccountUser,
  ]

  # PROVISIONING
  ######################################################################################################################
  provider         = google-beta
  location         = var.gcp-region
  name             = "main"
  description      = "Main cluster."
  enable_autopilot = true

  # NETWORKING
  # - by specifying VPC_NATIVE, the provider requires specifying an empty "ip_allocation_policy" clause
  ######################################################################################################################
  network         = google_compute_network.default.self_link
  subnetwork      = google_compute_subnetwork.gke.self_link
  networking_mode = "VPC_NATIVE"
  allow_net_admin = true
  ip_allocation_policy {
    services_secondary_range_name = google_compute_subnetwork.gke.secondary_ip_range.0.range_name
    cluster_secondary_range_name  = google_compute_subnetwork.gke.secondary_ip_range.1.range_name
  }
  dns_config {
    cluster_dns        = "CLOUD_DNS"
    cluster_dns_domain = "cluster.local"
    cluster_dns_scope  = "CLUSTER_SCOPE"
  }
  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }

  # OPERATIONS
  # TODO: add "notification_config" to send Pub/Sub messages when cluster is being upgraded
  ######################################################################################################################
  release_channel {
    channel = "STABLE"
  }
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
    # TODO: enable metrics collection for builtin kubernetes components as well as workloads
  }
  maintenance_policy {
    daily_maintenance_window {
      start_time = "01:00"
    }
  }

  # SECURITY
  ######################################################################################################################
  authenticator_groups_config {
    security_group = "gke-security-groups@${data.google_organization.kfirfamily.domain}"
  }
}
