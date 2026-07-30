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

  environment                   = "staging"
  db_url                        = var.db_url
  clerk_jwt_issuer_uri          = var.clerk_jwt_issuer_uri
  firebase_service_account_json = var.firebase_service_account_json
  cors_allowed_origins          = ["https://staging-ringsatranarvi-app.web.app", "http://localhost:5173"]
}
