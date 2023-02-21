provider "google" {
  project = var.project_id
  region  = "asia-northeast3"
  zone    = "asia-northeast3-b"
}

resource "google_service_account" "default" {
  account_id   = "${var.vm_name}serviceaccount"
  display_name = "Service Account"
}

module "network" {
  source          = "./modules/network"
  for_each        = var.resource_name
  project_id      = var.project_id
  vpc_name        = each.value.vpc_name
  subnetwork_name = each.value.subnetwork_name
}
module "compute-vm" {
  source          = "./modules/compute-vm"
  for_each        = var.resource_name
  vm_name         = each.value.vm_name
  network         = module.network[each.key].vpc_name
  subnetwork      = module.network[each.key].subnetwork
  service_account = google_service_account.default.email
}

# resource "google_compute_firewall" "default" {
#   depends_on = [
#     module.network
#   ]
#   name    = "test-firewall"
#   network = var.vpc_name

#   allow {
#     protocol = "icmp"
#   }

#   allow {
#     protocol = "tcp"
#     ports    = ["80", "8080", "22"]
#   }
#   source_ranges = ["0.0.0.0/0"]
#   target_tags   = ["web"]
# }

# output "vm_ip" {
#     value =  [for i in google_compute_instance.default :i.network_interface[0].network_ip]
# }

# output "vm_name" {
#     value =  [for i in google_compute_instance.default : i.name]
# }

# output "vm_name_ip" {
#     value = {for i in google_compute_instance.default : i.name => "int:${i.network_interface[0].network_ip},ext:${i.network_interface[0].access_config[0].nat_ip}"}
# }

# resource "random_string" "random" {
#   count   = 2
#   length  = 4
#   special = false
#   upper   = false
# }

