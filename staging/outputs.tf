# ==========================================
# OUTPUTS FOR STAGING
# ==========================================

output "frontend_url" {
  value       = module.app.FRONTEND_URL
  description = "Frontend Firebase Hosting URL for Staging"
}

output "neon_username" {
  value       = module.app.GENERATED_NEON_USERNAME
  description = "NEON username for Staging"
}