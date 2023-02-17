resource "google_compute_network" "vpc_network" {
  project                 = var.project_id 
  name                    = var.vpc_name  
  auto_create_subnetworks = false         
  mtu                     = 1460        
}

resource "google_compute_subnetwork" "subnetwork" {
  depends_on = [
    google_compute_network.vpc_network
  ]
  name          = var.subnetwork_name
  ip_cidr_range = "10.3.0.0/16"
  region        = "asia-northeast3"
  network       = var.vpc_name
}