output "vpc_name" {
  value = google_compute_network.vpc_network.name
}

output "subnetwork" {
  value = google_compute_subnetwork.subnetwork.self_link
}