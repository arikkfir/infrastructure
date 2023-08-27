output "main-gke-cluster-name" {
  value = google_container_cluster.main.name
}

output "main-gke-cluster-location" {
  value = google_container_cluster.main.location
}
