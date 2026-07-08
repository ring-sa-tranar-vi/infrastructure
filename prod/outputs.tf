# ==========================================
# OUTPUTS FOR PROD
# ==========================================

output "frontend_url" {
  value       = module.app.FRONTEND_URL
  description = "Frontend Firebase Hosting URL for Prod"
}

output "neon_username" {
  value       = module.app.GENERATED_NEON_USERNAME
  description = "NEON username for Prod"
}

output "neon_password" {
  value       = module.app.GENERATED_NEON_PASSWORD
  sensitive   = true
  description = "NEON password for Prod"
}