resource "google_container_cluster" "arc" {
  depends_on = [
    google_project_service.apis["cloudresourcemanager.googleapis.com"],
    google_project_service.apis["compute.googleapis.com"],
    google_project_service.apis["container.googleapis.com"],
    google_project_service.apis["containerfilesystem.googleapis.com"],
    google_project_service.apis["dns.googleapis.com"],
    google_project_service.apis["iam.googleapis.com"],
    google_project_service.apis["iamcredentials.googleapis.com"],
    google_project_service.apis["logging.googleapis.com"],
    google_project_service.apis["monitoring.googleapis.com"],
    google_project_service.apis["pubsub.googleapis.com"],
    google_project_service.apis["secretmanager.googleapis.com"],
    google_project_service.apis["servicemanagement.googleapis.com"],
    google_project_service.apis["serviceusage.googleapis.com"],
    google_service_account_iam_member.default-compute-infrastructure-iam-serviceAccountUser,
  ]

  # PROVISIONING
  ######################################################################################################################
  provider    = google-beta
  location    = local.gcp_zone_a
  name        = "arc"
  description = "GitHub Actions Runner Controller (ARC)."
  timeouts {
    create = "60m"
    update = "60m"
  }

  # NETWORKING
  ######################################################################################################################
  network         = data.google_compute_network.default.self_link
  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {}

  # SCALING
  ######################################################################################################################
  cluster_autoscaling {
    # This disables the automatic node-pool creation, not the per-node-pool autoscaling
    enabled = false

    # This ensures the cluster only uses what it needs
    # TODO: autoscaling_profile = "OPTIMIZE_UTILIZATION"
  }

  # OPERATIONS
  ######################################################################################################################
  release_channel {
    channel = "STABLE"
    # TODO: channel = "RAPID"
  }
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
    managed_prometheus {
      # TODO: enabled = true
      enabled = false
    }
  }
  maintenance_policy {
    daily_maintenance_window {
      start_time = "04:00"
    }
  }

  # SECURITY
  ######################################################################################################################
  authenticator_groups_config {
    security_group = "gke-security-groups@${data.google_organization.kfirfamily.domain}"
  }
  workload_identity_config {
    workload_pool = "${data.google_project.arik-kfir.project_id}.svc.id.goog"
  }

  # ADDONS
  ######################################################################################################################
  addons_config {
    //noinspection HCLUnknownBlockType
    config_connector_config {
      enabled = true
    }
    #    http_load_balancing {
    #      TODO: disabled = true
    #    }
  }

  # SYSTEM NODE POOL
  ######################################################################################################################
  node_pool {
    name           = "default-pool"
    node_locations = [local.gcp_zone_a]

    # SCALING
    ######################################################################################################################
    autoscaling {
      total_min_node_count = 1
      total_max_node_count = 3
      location_policy      = "ANY"
    }

    # OPERATIONS
    ######################################################################################################################
    management {
      auto_repair  = true
      auto_upgrade = true
    }
    upgrade_settings {
      max_surge       = 3
      max_unavailable = 0
    }

    # DEFAULT NODE POOL'S NODE CONFIG
    ######################################################################################################################
    node_config {
      disk_size_gb = 100
      disk_type    = "pd-standard"
      labels = {
        "gke.kfirs.com/purpose" : "system"
      }
      machine_type = "e2-standard-4"
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform",
      ]
      service_account = data.google_compute_default_service_account.arik-kfir.email
      spot            = true
      workload_metadata_config {
        mode = "GKE_METADATA"
      }
    }
  }

  # WORKLOADS NODE POOL
  ######################################################################################################################
  node_pool {
    name           = "e2-standard-8-workloads"
    node_locations = [local.gcp_zone_a]

    # SCALING
    ######################################################################################################################
    autoscaling {
      total_min_node_count = 0
      total_max_node_count = 3
      location_policy      = "ANY"
    }

    # OPERATIONS
    ######################################################################################################################
    management {
      auto_repair  = true
      auto_upgrade = true
    }
    upgrade_settings {
      max_surge       = 3
      max_unavailable = 0
    }

    # NODE CONFIG
    ######################################################################################################################
    node_config {
      disk_size_gb = 100
      disk_type    = "pd-standard"
      labels = {
        "gke.kfirs.com/purpose" : "workloads"
      }
      machine_type = "e2-standard-8"
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform",
      ]
      service_account = data.google_compute_default_service_account.arik-kfir.email
      spot            = true
      workload_metadata_config {
        mode = "GKE_METADATA"
      }
      taint = [
        {
          key    = "gke.kfirs.com/purpose"
          value  = "workloads"
          effect = "NO_EXECUTE"
        },
      ]
    }
  }

  # LIFECYCLE
  ######################################################################################################################
  lifecycle {
    ignore_changes = [
      # GKE can add custom labels & taints, therefore we must ignore them and trust that GKE will not delete ours
      node_config.0.labels,
      node_config.0.taint,
      node_config.1.labels,
      node_config.1.taint,
    ]
  }
}

output "arc_gke_cluster_name" {
  value = google_container_cluster.arc.name
}

output "arc_gke_cluster_location" {
  value = google_container_cluster.arc.location
}
