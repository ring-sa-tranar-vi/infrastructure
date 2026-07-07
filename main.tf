# ==========================================
# TERRAFORM & PROVIDER CONFIGURATION
# ==========================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 7.0"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  backend "gcs" {
    bucket = "ringsatranarvi-terraform-state"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = "ringsatranarvi"
  region = "europe-west3"
}

# ==========================================
# RANDOM STRING & PASSWORD FOR NEON
# ==========================================

resource "random_string" "db_username" {
  length  = 8
  special = false
  upper   = false
}

resource "random_password" "db_password" {
  length           = 48
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# ==========================================
# SECRET MANAGER
# ==========================================

resource "google_secret_manager_secret" "db_password" {
  secret_id = "neon-db-password"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_password_val" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db_password.result
}

resource "google_secret_manager_secret" "ai_api_key" {
  secret_id = "ai-api-key"
  replication {
    auto {}
  }
}

# ==========================================
# CLOUD RUN SERVICE
# ==========================================

resource "google_cloud_run_v2_service" "backend" {
  name = "backend-service"
  location = "europe-west3"

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"

      resources {
        limits = {
          memory = "512Mi"
          cpu    = "1"
        }
      }

      env {
        name  = "DB_USERNAME"
        value = "app_user_${random_string.db_username.result}"
      }
      env {
        name  = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret = google_secret_manager_secret.db_password.id
            version = "latest"
          }
        }
      }
    }
  }
}

resource "google_cloud_run_v2_service_iam_binding" "public_acess" {
  name = google_cloud_run_v2_service.backend.name
  location = google_cloud_run_v2_service.backend.location
  role    = "roles/run.invoker"
  members = [
    "allUsers",
  ]
}

data "google_project" "project" {}

resource "google_secret_manager_secret_iam_binding" "allow_cloud_run_db" {
  secret_id = google_secret_manager_secret.db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members   = [
    "serviceAccount:service-${data.google_project.project.number}@serverless-robot-prod.iam.gserviceaccount.com"
  ]
}

# ==========================================
# OUTPUTS (ATT KOPIERA TILL NEON)
# ==========================================

output "GENERATED_NEON_USERNAME" {
  value       = "app_user_${random_string.db_username.result}"
  description = "NEON username"
}

output "GENERATED_NEON_PASSWORD" {
  value       = random_password.db_password.result
  sensitive   = true
  description = "NEON password"
}