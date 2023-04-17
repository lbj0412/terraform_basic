resource "google_service_account" "default" {
  account_id   = "tf-template"
  display_name = "Service Account"
}

resource "google_project_iam_binding" "project" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  members = [
    "serviceAccount:${google_service_account.default.email}"
  ]
}
resource "google_compute_instance_template" "default" {
  name        = "lbj-test-1"
  description = "This template is used to create app server instances."

  tags = ["iap", "http", "int"]

  instance_description = "description assigned to instances"
  machine_type         = "e2-medium"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // Create a new boot disk from an image
  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnetwork.id
    network_ip = ""
  }

  metadata_startup_script = <<EOF
    #!/bin/bash
    apt-get install -y apache2
    systemctl start apache2
    apt update && sudo apt install wget -y
    wget https://repo.mysql.com//mysql-apt-config_0.8.22-1_all.deb
    export DEBIAN_FRONTEND=noninteractive
    sudo -E dpkg -i mysql-apt-config_0.8.22-1_all.deb
    apt-get update
    sudo -E apt-get -y install mysql-community-server
    EOF


  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}