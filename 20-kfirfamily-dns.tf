resource "google_dns_managed_zone" "kfirfamily-zone" {
  project = google_project.project.project_id
  name = "kfirfamily-zone"
  dns_name = "kfirfamily.com."
  visibility = "public"
}

# TODO: fill-in MX DNS records for kfirfamily.com zone
