resource "google_compute_firewall" "http-fw" {
  name        = "tf-fw-http"
  network     = google_compute_network.vpc_network.id
  target_tags = ["http"]
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
}

resource "google_compute_firewall" "internal-fw" {
  name        = "tf-fw-int"
  network     = google_compute_network.vpc_network.id
  target_tags = ["int"]
  allow {
    protocol = "tcp"
    ports    = []
  }
  source_ranges = ["192.168.0.0/24"]
}

resource "google_compute_firewall" "iap-fw" {
  name        = "tf-fw-iap"
  network     = google_compute_network.vpc_network.id
  target_tags = ["iap"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
}