resource "google_container_node_pool" "work_node_pool" {

  # GENERAL
  ######################################################################################################################
  name           = "work"
  location       = google_container_cluster.main.location
  cluster        = google_container_cluster.main.name
  project        = google_container_cluster.main.project
  node_locations = [local.gcp_zone_a]

  # AUTOSCALING
  ######################################################################################################################
  upgrade_settings {
    max_surge       = 2
    max_unavailable = 0
    strategy        = "SURGE"
  }
  autoscaling {
    total_min_node_count = 0
    total_max_node_count = 5
    location_policy      = "ANY"
  }

  # NODE CONFIGURATION
  ######################################################################################################################
  node_config {
    disk_size_gb = 100
    disk_type    = "pd-standard"

    labels = {
      "node.kfirs.com/role" = "work"
    }

    machine_type    = "e2-standard-4"
    service_account = data.google_compute_default_service_account.default.email
    preemptible     = false
    spot            = true

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    taint {
      key    = "node.kfirs.com/role"
      value  = "work"
      effect = "NO_EXECUTE"
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  # OPERATIONS
  ######################################################################################################################
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # LIFECYCLE
  ######################################################################################################################
  lifecycle {
    ignore_changes = [node_config.0.taint]
  }
}
