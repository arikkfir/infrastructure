resource "google_compute_network" "default" {
  name                    = "default"
  description             = "Default network for general services in the project."
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke" {
  network       = google_compute_network.default.id
  name          = "gke"
  ip_cidr_range = "10.2.0.0/16"
  region        = "me-west1"
  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "192.168.1.0/24"
  }
  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = "192.168.64.0/22"
  }
}
