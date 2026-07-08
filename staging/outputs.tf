output "GENERATED_NEON_USERNAME" {
  value       = app.random_string.db_username.result
  description = "NEON username"
}

output "GENERATED_NEON_PASSWORD" {
  value       = app.google_secret_manager_secret_version.db_password_val.secret_data
  sensitive   = true
  description = "NEON password"
}