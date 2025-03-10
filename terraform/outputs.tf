output "project_id" {
  description = "ID of project"
  value       = var.project_id
}

output "customer_id" {
  description = "ID of customer"
  value       = var.customer_id
}

output "region" {
  description = "main region"
  value       = var.region
}

output "gke_name" {
  description = "name of the cluster"
  value       = module.gke.name
}
