### provider 설정
provider "google" {
  project = var.project_id
  region  = "asia-northeast3"
  zone    = "asia-northeast3-b"
}

### network 설정
module "network" {
  source          = "./modules/network"
  project_id      = var.project_id
  vpc_name        = "byungjun-test"
  subnetwork_name = "byungjun-sbn"
}

### compute vm 설정
module "compute-vm" {
  source     = "./modules/compute-vm"
  vm_name    = var.vm_name
  network    = module.network.vpc_name
  subnetwork = module.network.subnetwork
}

resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = var.vpc_name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}

# output "vm_ip" {
#     value =  [for i in google_compute_instance.default :i.network_interface[0].network_ip]
# }

# output "vm_name" {
#     value =  [for i in google_compute_instance.default : i.name]
# }

# output "vm_name_ip" {
#     value = {for i in google_compute_instance.default : i.name => "int:${i.network_interface[0].network_ip},ext:${i.network_interface[0].access_config[0].nat_ip}"}
# }

resource "random_string" "random" {
  count   = 4
  length  = 4
  special = false
  upper   = false
}

