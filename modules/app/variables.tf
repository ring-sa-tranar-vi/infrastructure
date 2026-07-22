variable "environment" {
  description = "Environment name (staging/prod)"
  type        = string
  default     = "staging"
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "ringsatranarvi"
}

variable "default_region" {
  description = "Default GCP region"
  type        = string
  default     = "europe-north2"
}

variable "backend_location" {
  description = "GCP region for Cloud Run backend"
  type        = string
  default     = "europe-west3"
}

variable "cloud_run_cpu" {
  description = "Cloud Run CPU allocation"
  type        = string
  default     = "1"
}

variable "cloud_run_memory" {
  description = "Cloud Run memory allocation"
  type        = string
  default     = "512Mi"
}

variable "service_account_id" {
  description = "Service account ID for Cloud Run"
  type        = string
  default     = "ringsatranarvi-default"
}

variable "db_url" {
  description = "Database URL"
  type        = string
}

variable "clerk_jwt_issuer_uri" {
  description = "Clerk JWT Issuer URI"
  type        = string
  sensitive   = true
}

variable "gcp_storage_bucket_name" {
  description = "GCP Storage Bucket Name"
  type        = string
  default     = "ringsatranarvi-files"
}