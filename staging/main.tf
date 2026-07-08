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
}