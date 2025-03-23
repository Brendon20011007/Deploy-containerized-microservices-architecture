output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "appmesh_mesh_name" {
  description = "Name of the App Mesh mesh"
  value       = module.appmesh.mesh_name
}

output "monitoring_endpoint" {
  description = "Endpoint for the monitoring stack"
  value       = module.monitoring.endpoint
}

output "services_endpoints" {
  description = "Endpoints for the deployed microservices"
  value       = module.services.endpoints
} 