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
  name                     = var.subnetwork_name
  ip_cidr_range            = "10.0.0.0/24"
  region                   = "asia-northeast3"
  network                  = var.vpc_name
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

### Service account 생성 ###
resource "google_service_account" "sa" {
  account_id   = "myserviceaccount"
  display_name = "A service account that access gcs"
}
resource "google_project_iam_member" "project-roles" {
  project = var.project_id
    member  = "serviceAccount:${google_service_account.sa.email}"
    role    = "roles/storage.objectAdmin"
}


### Compute instance template 생성 ###
resource "google_compute_instance_template" "default" {
  name_prefix = "instance-template-"
  description = "This template is used to create web server instances."

  instance_description = "description assigned to instances"
  machine_type         = "e2-medium"
  can_ip_forward       = false
  tags                 = ["web"]
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // Create a new boot disk from an image
  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
    // backup the disk every day
  }
  lifecycle {
    create_before_destroy = true
  }


  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.subnetwork.self_link
  }
  metadata_startup_script = <<EOF
    #!/bin/bash
    apt update && sudo apt -y  install wget
    wget https://repo.mysql.com//mysql-apt-config_0.8.22-1_all.deb
    dpkg -i mysql-apt-config_0.8.22-1_all.deb
    apt-get update
    apt-get -y install mysql-community-server
    systemctl start mysql
    apt-get install -y apache2
    systemctl start apache2
    EOF


  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.sa.email
    scopes = ["cloud-platform"]
  }
}

### Compute instance group 생성 ###
resource "google_compute_instance_group_manager" "instance_group_manager" {
  name = "instance-group-manager"
  version {
    instance_template = google_compute_instance_template.default.id
  }
  named_port {
    name = "http"
    port = 80
  }
  base_instance_name = "vm"
  zone               = "asia-northeast3-a"
  target_size        = "2"
}


### Firewall rule 생성 ###

resource "google_compute_firewall" "healthcheck" {
  depends_on = [
    google_compute_network.vpc_network
  ]
  name    = "healthcheck-firewall"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = ["web"]
}

resource "google_compute_firewall" "ssh-iap" {
  depends_on = [
    google_compute_network.vpc_network
  ]
  name    = "ssh-firewall"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["web"]
}
resource "google_compute_firewall" "internal" {
  depends_on = [
    google_compute_network.vpc_network
  ]
  name    = "internal-firewall"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = []
  }
  source_ranges = ["10.0.0.0/8"]
  target_tags   = ["web"]
}

### GCS 생성 ###
resource "google_storage_bucket" "bucket" {
  name          = "bjlee-self-test-bucket"
  location      = "asia-northeast3"
  force_destroy = true
}