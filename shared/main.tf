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

# ==========================================
# GRAFANA MONITORING SERVICE ACCOUNT
# ==========================================

resource "google_service_account" "grafana_monitoring" {
  account_id   = "grafana-monitoring-sa"
  display_name = "Grafana Cloud Monitoring Service Account"
}

resource "google_project_iam_member" "grafana_monitoring_viewer" {
  project = "ringsatranarvi"
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.grafana_monitoring.email}"
}

resource "google_project_iam_member" "grafana_compute_viewer" {
  project = "ringsatranarvi"
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.grafana_monitoring.email}"
}