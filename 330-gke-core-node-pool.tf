resource "google_container_node_pool" "core_node_pool" {

  # GENERAL
  ######################################################################################################################
  name           = "core"
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
    total_min_node_count = 1
    total_max_node_count = 3
    location_policy      = "ANY"
  }

  # NODE CONFIGURATION
  ######################################################################################################################
  node_config {
    disk_size_gb = 100
    disk_type    = "pd-standard"

    labels = {
      "node.kfirs.com/role" = "core"
    }

    machine_type    = "e2-standard-4"
    service_account = google_service_account.gke-node.email
    spot            = true

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

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
}
