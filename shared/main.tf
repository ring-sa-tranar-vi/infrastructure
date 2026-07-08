terraform {
  backend "gcs" {
    bucket = "ringsatranarvi-terraform-state"
    prefix = "terraform/state/shared"
  }
}

provider "google" {
  project = "ringsatranarvi"
  region  = "europe-north2"
}

resource "google_artifact_registry_repository" "shared_repo" {
  location      = "europe-north2"
  repository_id = "ringsatranarvi-shared-repo"
  description   = "Shared Artifact Registry Repository for Docker images"
  format        = "DOCKER"
}