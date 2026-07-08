# ==========================================
# OUTPUTS FOR PROD
# ==========================================

output "frontend_url" {
  value       = module.app.FRONTEND_URL
  description = "Frontend Firebase Hosting URL for Prod"
}