output "main_gke_cluster_name" {
  value = google_container_cluster.main.name
}

output "main_gke_cluster_location" {
  value = google_container_cluster.main.location
}
