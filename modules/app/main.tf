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
    google-beta = {
      source = "hashicorp/google-beta"
      version = "~> 7.0"
    }
  }
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
  secret_id = "${var.environment}-neon-db-password"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_password_val" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db_password.result
}

resource "google_secret_manager_secret" "ai_api_key" {
  secret_id = "${var.environment}-ai-api-key"
  replication {
    auto {}
  }
}

# ==========================================
# CLOUD RUN SERVICE
# ==========================================

resource "google_cloud_run_v2_service" "backend" {
  name = "${var.environment}-backend-service"
  location = var.backend_location

  template {
    service_account = data.google_service_account.sa_account.email

    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"

      resources {
        limits = {
          memory = var.cloud_run_memory
          cpu    = var.cloud_run_cpu
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

data "google_service_account" "sa_account" {
  account_id = var.service_account_id
}

resource "google_secret_manager_secret_iam_member" "allow_cloud_run_db" {
  secret_id = google_secret_manager_secret.db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member   = "serviceAccount:${data.google_service_account.sa_account.email}"
}

# ==========================================
# FRONTEND FIREBASE HOSTING
# ==========================================

resource "google_project_service" "firebase" {
  service = "firebase.googleapis.com"
  disable_on_destroy = false
}

resource "google_firebase_project" "default" {
  provider = google-beta
  project = var.project_id
  depends_on = [google_project_service.firebase]
}

resource "google_firebase_hosting_site" "frontend" {
  provider = google-beta
  project = var.project_id
  site_id = "${var.environment}-frontend-app"
  depends_on = [google_firebase_project.default]
}

# ==========================================
# OUTPUTS
# ==========================================

output "FRONTEND_URL" {
  value       = "https://${google_firebase_hosting_site.frontend.default_url}"
  description = "Frontend Firebase Hosting URL"
}

output "GENERATED_NEON_USERNAME" {
  value       = "app_user_${random_string.db_username.result}"
  description = "NEON username"
}

output "GENERATED_NEON_PASSWORD" {
  value       = random_password.db_password.result
  sensitive   = true
  description = "NEON password"
}