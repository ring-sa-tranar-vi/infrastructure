terraform {
  backend "gcs" {
    bucket = "ringsatranarvi-terraform-state"
    prefix = "terraform/state/shared"
  }
}

provider "google" {
  project = var.project_id
  region  = var.default_region
}

# ==========================================
# ARTIFACT REGISTRY REPOSITORY
# ==========================================

resource "google_artifact_registry_repository" "shared_repo" {
  location      = var.default_region
  repository_id = "${var.project_id}-shared-repo"
  description   = "Shared Artifact Registry Repository for Docker images"
  format        = "DOCKER"
}

# ==========================================
# CLOUD STORAGE: BUCKET FOR AUDIO FILES
# ==========================================

resource "google_storage_bucket" "files" {
  name          = "${var.project_id}-files"
  project       = var.project_id
  location      = var.default_region
  public_access_prevention = "enforced"
  force_destroy = false
  uniform_bucket_level_access = true
}

data "google_service_account" "sa_account" {
  account_id   = var.service_account_id
}

resource "google_storage_bucket_iam_member" "allow_service_account_access" {
  bucket = google_storage_bucket.files.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${data.google_service_account.sa_account.email}"
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

# ==========================================
# SECRET MANAGER SHARED SECRETS
# ==========================================

resource "google_secret_manager_secret" "grafana_otlp_url" {
  secret_id = "grafana-otlp-url"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "grafana_otlp_url_initial" {
  secret      = google_secret_manager_secret.grafana_otlp_url.id
  secret_data = "placeholder-grafana-otlp-url"

  lifecycle {
    ignore_changes = [secret_data]
  }
}

resource "google_secret_manager_secret" "grafana_otlp_auth" {
  secret_id = "grafana-otlp-auth"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "grafana_otlp_auth_initial" {
  secret      = google_secret_manager_secret.grafana_otlp_auth.id
  secret_data = "placeholder-grafana-otlp-auth"

  lifecycle {
    ignore_changes = [secret_data]
  }
}