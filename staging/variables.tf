variable "grafana_otlp_url" {
  description = "URL for Grafana OTLP"
  type        = string
  sensitive   = true
}

variable "grafana_otlp_auth" {
  description = "Basic Auth for Grafana OTLP"
  type        = string
  sensitive   = true
}

variable "clerk_jwt_issuer_uri" {
  description = "Clerk JWT Issuer URI"
  type        = string
  sensitive   = true
}