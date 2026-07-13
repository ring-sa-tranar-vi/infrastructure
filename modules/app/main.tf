# ==========================================
# TERRAFORM & PROVIDER CONFIGURATION
# ==========================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
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

resource "google_secret_manager_secret" "gemini_api_key" {
  secret_id = "gemini-api-key"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "grafana_otlp_url" {
  secret_id = "grafana-otlp-url"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "grafana_otlp_auth" {
  secret_id = "grafana-otlp-auth"
  replication {
    auto {}
  }
}

# ==========================================
# CLOUD RUN SERVICE
# ==========================================

resource "google_cloud_run_v2_service" "backend" {
  name     = "${var.environment}-backend-service"
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
        name  = "SPRING_DATASOURCE_URL"
        value = var.db_url
      }
      env {
        name  = "SPRING_DATASOURCE_USERNAME"
        value = "app_user_${random_string.db_username.result}"
      }
      env {
        name  = "SPRING_DATASOURCE_PASSWORD"
        value_source {
          secret_key_ref {
            secret = google_secret_manager_secret.db_password.id
            version = "latest"
          }
        }
      }
      env {
        name = "SPRING_DATASOURCE_DRIVER_CLASS_NAME"
        value = "org.postgresql.Driver"
      }
      env {
          name  = "APP_ENVIRONMENT"
          value = var.environment
        }
      env {
        name  = "GRAFANA_OTLP_URL"
        value_source {
          secret_key_ref {
            secret = google_secret_manager_secret.grafana_otlp_url.id
            version = "latest"
          }
        }
      }
      env {
        name = "GRAFANA_OTLP_AUTH"
        value_source {
          secret_key_ref {
            secret = google_secret_manager_secret.grafana_otlp_auth.id
            version = "latest"
          }
        }
      }
      env {
        name = "GEMINI_API_KEY"
        value_source {
          secret_key_ref {
            secret = google_secret_manager_secret.gemini_api_key.id
            version = "latest"
          }
        }
      }
      env {
        name = "CLERK_JWT_ISSUER_URI"
        value = var.clerk_jwt_issuer_uri
      }
    }
  }
}

resource "google_cloud_run_v2_service_iam_binding" "public_acess" {
  name     = google_cloud_run_v2_service.backend.name
  location = google_cloud_run_v2_service.backend.location
  role     = "roles/run.invoker"
  members  = ["allUsers"]
}

data "google_service_account" "sa_account" {
  account_id = var.service_account_id
}

# Allow the Cloud Run service account to access the secrets in Secret Manager
resource "google_secret_manager_secret_iam_member" "allow_cloud_run_db" {
  secret_id = google_secret_manager_secret.db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_service_account.sa_account.email}"
}

resource "google_secret_manager_secret_iam_member" "allow_cloud_run_grafana_otlp_url" {
  secret_id = google_secret_manager_secret.grafana_otlp_url.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_service_account.sa_account.email}"
}

resource "google_secret_manager_secret_iam_member" "allow_cloud_run_grafana_otlp_auth" {
  secret_id = google_secret_manager_secret.grafana_otlp_auth.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_service_account.sa_account.email}"
}

resource "google_secret_manager_secret_iam_member" "allow_cloud_run_gemini_api_key" {
  secret_id = google_secret_manager_secret.gemini_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_service_account.sa_account.email}"
}

# ==========================================
# FRONTEND FIREBASE HOSTING
# ==========================================

resource "google_project_service" "firebase" {
  service            = "firebase.googleapis.com"
  disable_on_destroy = false
}

resource "google_firebase_project" "default" {
  provider   = google-beta
  project    = var.project_id
  depends_on = [google_project_service.firebase]
}

resource "google_firebase_hosting_site" "frontend" {
  provider   = google-beta
  project    = var.project_id
  site_id    = "${var.environment}-${var.project_id}-app"
  depends_on = [google_firebase_project.default]
}

# ==========================================
# ARTIFACT REGISTRY REPOSITORY
# ==========================================

data "google_artifact_registry_repository" "shared_repo" {
  location      = var.default_region
  repository_id = "ringsatranarvi-shared-repo"
}

resource "google_artifact_registry_repository_iam_member" "allow_cloud_run_pull" {
  project    = data.google_artifact_registry_repository.shared_repo.project
  location   = data.google_artifact_registry_repository.shared_repo.location
  repository = data.google_artifact_registry_repository.shared_repo.repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${data.google_service_account.sa_account.email}"
}

# ==========================================
# OUTPUTS
# ==========================================

output "FRONTEND_URL" {
  value       = google_firebase_hosting_site.frontend.default_url
  description = "Frontend Firebase Hosting URL"
}

output "GENERATED_NEON_USERNAME" {
  value       = "app_user_${random_string.db_username.result}"
  description = "NEON username"
}