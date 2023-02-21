### VPC Network###
module "vpc" {
  source     = "./modules/net-vpc"
  project_id = var.project_id
  name       = "${var.name}-vpc"
  subnets = [
    {
      ip_cidr_range = "10.0.0.0/24"
      name          = "${var.name}-sbn"
      region        = "asia-northeast3"
    },
  ]
  psa_config = {
    ranges = { cloud-sql = "10.60.0.0/16" }
    routes = null
  }
}
### Cloud NAT ###
module "nat" {
  source         = "./modules/net-cloudnat"
  project_id     = var.project_id
  region         = var.region
  name           = "byungjun-tf-cloudnat"
  router_network = module.vpc.name
}

### Service account ### 
module "default-service-accounts" {
  source     = "./modules/iam-service-account"
  project_id = var.project_id
  name       = var.name

  iam_project_roles = {
    "${var.project_id}" = [
      "roles/storage.admin",
    ]
  }
}
### Firewall ### 
module "firewall" {
  source     = "./modules/net-vpc-firewall"
  project_id = var.project_id
  network    = module.vpc.name
  default_rules_config = {
    admin_ranges = ["10.0.0.0/8"]
  }
}


### Template ### 
module "nginx-template" {
  source        = "./modules/compute-vm"
  project_id    = var.project_id
  name          = "${var.name}-nginx-template"
  zone          = "asia-northeast3-a"
  tags          = ["http-server", "ssh"]
  instance_type = "e2-medium"
  network_interfaces = [{
    network    = module.vpc.name
    subnetwork = module.vpc.subnet_self_links["${var.region}/${var.name}-sbn"]
    nat        = false
    addresses  = null
  }]
  boot_disk = {
    image = "projects/debian-cloud/global/images/family/debian-11"
    type  = "pd-ssd"
    size  = 10
  }
  create_template        = true
  service_account        = module.default-service-accounts.email
  service_account_scopes = ["cloud-platform"]
  metadata = {
    user-data = file("./startup_script")
  }
}

module "nginx-mig" {
  source            = "./modules/compute-mig"
  project_id        = var.project_id
  location          = "asia-northeast3-a"
  name              = "${var.name}-mig"
  target_size       = 2
  instance_template = module.nginx-template.template.self_link
  named_ports = {
    http = 80
  }
}

### HTTP LB ###
module "http-lb" {
  source     = "./modules/net-glb"
  project_id = var.project_id
  name       = "${var.name}-http-lb"
  backend_service_configs = {
    default = {
      backends = [
        { backend = module.nginx-mig.group_manager.instance_group },
      ]
    }
  }
}

resource "random_string" "cloudsql" {
  length  = 4
  special = false
  lower   = true
}

### CloudSQL ###
module "db" {
  source           = "./modules/cloudsql-instance"
  project_id       = var.project_id
  network          = module.vpc.self_link
  name             = "db-${var.name}-${random_string.cloudsql.result}"
  region           = var.region
  database_version = "MYSQL_8_0"
  tier             = "db-n1-standard-2"
  root_password    = "password"
}

module "bucket" {
  source        = "./modules/gcs"
  project_id    = var.project_id
  prefix        = var.name
  name          = "bucket"
  versioning    = true
  location      = "asia-northeast3"
  force_destroy = true
}