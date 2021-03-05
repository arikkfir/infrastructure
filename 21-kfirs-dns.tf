resource "google_dns_managed_zone" "kfirs-zone" {
  name        = "kfirs-zone"
  dns_name    = "kfirs.com."
  visibility = "public"
}

resource "google_dns_record_set" "kfirs-zone-k" {
  name         = "k.${google_dns_managed_zone.kfirs-zone.dns_name}"
  managed_zone = google_dns_managed_zone.kfirs-zone.name
  type         = "A"
  ttl          = 300
  rrdatas = [google_compute_address.gke_ingress.address]
}

# TODO: fill-in MX DNS records for kfirs.com zone
