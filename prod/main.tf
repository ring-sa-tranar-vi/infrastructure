terraform {
  backend "gcs" {
    bucket = "ringsatranarvi-terraform-state"
    prefix = "terraform/state/prod"
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
  environment = "prod"
  db_url      = "jdbc:postgresql://ep-sweet-unit-as7v1s28-pooler.c-4.eu-central-1.aws.neon.tech/production?sslmode=require&channelBinding=require"
}