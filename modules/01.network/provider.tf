terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.50.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = "asia-northeast3"
  zone    = "asia-northeast3-a"
}