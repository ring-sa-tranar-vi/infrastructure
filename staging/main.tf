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

import {
  to = module.app.google_secret_manager_secret.db_password
  id = "projects/49973934534/secrets/staging-neon-db-password"
}

import {
  to = module.app.google_secret_manager_secret.gemini_api_key
  id = "projects/49973934534/secrets/staging-gemini-api-key"
}

import {
  to = module.app.google_secret_manager_secret.openai_api_key
  id = "projects/49973934534/secrets/staging-openai-api-key"
}

module "app" {
  source      = "../modules/app"
  environment = "prod"
  db_url      = "jdbc:postgresql://ep-sweet-unit-as7v1s28-pooler.c-4.eu-central-1.aws.neon.tech/production?sslmode=require&channelBinding=require"
  clerk_jwt_issuer_uri = var.clerk_jwt_issuer_uri
  cors_allowed_origins = ["https://prod-ringsatranarvi-app.web.app"]
  firebase_service_account_json = var.firebase_service_account_json
}
