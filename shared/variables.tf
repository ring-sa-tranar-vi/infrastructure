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

variable "service_account_id" {
  description = "Service account ID for Cloud Run"
  type        = string
  default     = "ringsatranarvi-default"
}

variable "allowed_origins" {
  description = "List of allowed origins for Storage Bucket CORS configuration"
  type        = list(string)
  default     = ["https://staging-ringsatranarvi-app.web.app", "https://prod-ringsatranarvi-app.web.app"]
}