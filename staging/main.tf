terraform {
  backend "gcs" {
    bucket = "ringsatranarvi-terraform-state"
    prefix = "terraform/state/staging"
  }
}

provider "google" {
  project = "ringsatranarvi"
  region  = "europe-north2"
}

provider "google-beta" {
  project = "ringsatranarvi"
  region  = "europe-north2"
}

module "app" {
  source = "../modules/app"

  environment                   = var.environment
  project_id                    = var.project_id
  default_region                = var.default_region
  backend_location              = var.backend_location
  cloud_run_cpu                 = var.cloud_run_cpu
  cloud_run_memory              = var.cloud_run_memory
  service_account_id            = var.service_account_id
  db_url                        = var.db_url
  clerk_jwt_issuer_uri          = var.clerk_jwt_issuer_uri
  gcp_storage_bucket_name       = var.gcp_storage_bucket_name
  cors_allowed_origins          = var.cors_allowed_origins
  firebase_service_account_json = var.firebase_service_account_json
}
