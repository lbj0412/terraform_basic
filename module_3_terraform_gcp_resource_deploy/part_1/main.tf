### 1. Provider 설정
provider "google" {
  project = project_id
  region  = "asia-northeast3"
  zone    = "asia-northeast3-a"
}

### 2. VPC 네트워크 생성
resource "google_compute_network" "vpc_network" {
  project                 = project_id
  name                    = "tf-vpc-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

### 3. 서브넷 생성
resource "google_compute_subnetwork" "subnetwork" {
  depends_on = [
    google_compute_network.vpc_network
  ]
  name          = "tf-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "asia-northeast3"
  network       = "tf-vpc-network"
}

### 4. 서비스 계정 생성
resource "google_service_account" "default" {
  account_id   = "serviceaccountid"
  display_name = "Service Account"
}


### 5. 인스턴스 생성
resource "google_compute_instance" "default" {
  name         = "test"
  machine_type = "e2-medium"
  zone         = "asia-northeast3-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  tags = ["web"]
  network_interface {
    network    = "tf-vpc-network"
    subnetwork = subnetwork_self_link

    access_config {
      // Ephemeral public IP
    }
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}

### 6. 방화벽 생성
resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = "tf-vpc-network"

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}
