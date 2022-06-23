output "project_directory_path" {
  value       = databricks_directory.prod_directory.path
  description = "Path/Name of Databricks workspace directory created for the project."
}

output "staging_service_principal_application_id" {
  value       = module.staging_sp.service_principal_application_id
  description = "Application ID of the created Databricks service principal in the staging workspace."
}

output "staging_service_principal_token" {
  value       = module.staging_sp.service_principal_token
  sensitive   = true
  description = "Sensitive personal access token (PAT) value of the created Databricks service principal in the staging workspace."
}

output "prod_service_principal_application_id" {
  value       = module.prod_sp.service_principal_application_id
  description = "Application ID of the created Databricks service principal in the prod workspace."
}

output "prod_service_principal_token" {
  value       = module.prod_sp.service_principal_token
  sensitive   = true
  description = "Sensitive personal access token (PAT) value of the created Databricks service principal in the prod workspace."
}
