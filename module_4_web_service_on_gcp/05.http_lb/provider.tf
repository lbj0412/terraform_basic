provider "google" {
  project = var.project_id
  region  = "asia-northeast3"
  zone    = "asia-northeast3-a"
}

provider "google-beta" {
  project = var.project_id
  region  = "asia-northeast3"
  zone    = "asia-northeast3-a"
}