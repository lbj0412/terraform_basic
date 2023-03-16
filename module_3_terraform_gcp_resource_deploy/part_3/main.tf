### 1. Provider 설정
provider "google" {
  project = var.project_id
  region  = "asia-northeast3"
  zone    = "asia-northeast3-a"
}

### 2. VPC 네트워크 생성
resource "google_compute_network" "vpc_network" {
  project                 = var.project_id
  name                    = var.vpc_name
  auto_create_subnetworks = false
  mtu                     = 1460
}

### 3. 서브넷 생성
resource "google_compute_subnetwork" "subnetwork" {
  depends_on = [
    google_compute_network.vpc_network
  ]
  name          = var.subnetwork_name
  ip_cidr_range = "10.2.0.0/16"
  region        = "asia-northeast3"
  network       = var.vpc_name
}

### 4. 서비스 계정 생성
resource "google_service_account" "default" {
  account_id   = "serviceaccountid"
  display_name = "Service Account"
}


### 5. 인스턴스 생성 Count 설정
resource "google_compute_instance" "default" {
  count        = 4
  name         = "${var.vm_name}-${count.index + 1}" // "${var.vm_name}-${random_string.random[count.index].result}"
  machine_type = "e2-medium"
  zone         = "asia-northeast3-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  //metadata_startup_script = file("./startup_script")
  tags = ["web"]
  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.subnetwork.self_link

    access_config {
      // Ephemeral public IP
    }
  }
  metadata_startup_script = file("./startup_script")
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}

### 6. 방화벽 생성
resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}


## 7. output 설정
output "instance_name" {
  value = google_compute_instance.default.name
}

output "instance_ip" {
  value = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
}

## 7.1 output 복수의 vm이름과 IP 설정
# output "instance_ip" {
#     value =  [for i in google_compute_instance.default :i.network_interface[0].network_ip]
# }
# output "instance_name" {
#     value =  [for i in google_compute_instance.default : i.name]
# }

## 7.2 output vm이름과 IP 동시설정
# output "vm_name_ip" {
#     value = {for i in google_compute_instance.default : i.name => "int:${i.network_interface[0].network_ip},ext:${i.network_interface[0].access_config[0].nat_ip}"}
# }


### 8. random_string 생성
resource "random_string" "random" {
  count   = 4
  length  = 4
  special = false
  upper   = false
}