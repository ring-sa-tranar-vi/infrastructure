variable "db_url" {
  description = "Database URL"
  type        = string
  sensitive   = true
}

variable "clerk_jwt_issuer_uri" {
  description = "Clerk JWT Issuer URI"
  type        = string
  sensitive   = true
}

variable "firebase_service_account_json" {
  description = "Firebase Service Account JSON"
  type        = string
  sensitive   = true
}
