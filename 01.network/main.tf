### VPC Network 생성 ###
resource "google_compute_network" "vpc_network" {
  project                 = var.project_id
  name                    = var.vpc_name
  auto_create_subnetworks = false
  mtu                     = 1460
}

### Subnetwork 생성 ###
resource "google_compute_subnetwork" "subnetwork" {
  depends_on = [
    google_compute_network.vpc_network
  ]
  name          = var.subnetwork_name
  ip_cidr_range = "10.0.0.0/24"
  region        = "asia-northeast3"
  network       = var.vpc_name
  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  name    = "my-router"
  region  = google_compute_subnetwork.subnetwork.region
  network = google_compute_network.vpc_network.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "my-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}