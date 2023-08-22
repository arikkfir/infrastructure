resource "google_compute_network" "default" {
  name                    = "default"
  description             = "Default network for general services in the project."
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke" {
  network       = google_compute_network.default.id
  name          = "gke"
  ip_cidr_range = "10.1.0.0/16"
  region        = "me-west1"
  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "10.10.0.0/16"
  }
  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = "10.20.0.0/16"
  }
}

resource "google_compute_firewall" "default-allow-internal" {
  name          = "default-allow-internal"
  network       = google_compute_network.default.name
  disabled      = false
  priority      = 65534
  direction     = "INGRESS"
  source_ranges = [
    "10.1.0.0/16",
    "10.10.0.0/16",
    "10.20.0.0/16",
  ]

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
}

resource "google_compute_firewall" "default-allow-ssh" {
  name          = "default-allow-ssh"
  network       = google_compute_network.default.name
  disabled      = false
  priority      = 65534
  direction     = "INGRESS"
  source_ranges = [
    "0.0.0.0/0",
  ]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "default-allow-rdp" {
  name          = "default-allow-rdp"
  network       = google_compute_network.default.name
  disabled      = false
  priority      = 65534
  direction     = "INGRESS"
  source_ranges = [
    "0.0.0.0/0",
  ]

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
}

resource "google_compute_firewall" "default-allow-icmp" {
  name          = "default-allow-icmp"
  network       = google_compute_network.default.name
  disabled      = false
  priority      = 65534
  direction     = "INGRESS"
  source_ranges = [
    "0.0.0.0/0",
  ]

  allow {
    protocol = "icmp"
  }
}
