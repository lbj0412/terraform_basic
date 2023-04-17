resource "google_storage_bucket" "static-site" {
  name                        = "tf-test-gcs"
  location                    = "ASIA"
  force_destroy               = true
  uniform_bucket_level_access = true
}