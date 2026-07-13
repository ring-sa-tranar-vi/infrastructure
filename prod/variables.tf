variable "grafana_otlp_url" {
  description = "URL för Grafana OTLP"
  type        = string
  sensitive   = true
}

variable "grafana_otlp_auth" {
  description = "Basic Auth för Grafana OTLP"
  type        = string
  sensitive   = true
}