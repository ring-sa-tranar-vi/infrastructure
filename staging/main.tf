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
  source      = "../modules/app"
  environment = "staging"
  db_url      = "jdbc:postgresql://ep-sweet-unit-as7v1s28-pooler.c-4.eu-central-1.aws.neon.tech/staging?sslmode=require&channelBinding=require"
  clerk_jwt_issuer_uri = var.clerk_jwt_issuer_uri
  cors_allowed_origins = ["https://staging-ringsatranarvi-app.web.app"]
}