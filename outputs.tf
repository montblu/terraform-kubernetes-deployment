output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = try(aws_ecr_repository.main[0].repository_url, "")
}

output "deployment_name" {
  description = "The name of the deployment"
  value       = try(kubernetes_deployment.main[0].metadata[0].name, "")
}

output "deployment_labels" {
  description = "The labels of the deployment"
  value       = try(kubernetes_deployment.main[0].metadata[0].labels, {})
}

output "deployment_annotations" {
  description = "The annotations of the deployment"
  value       = try(kubernetes_deployment.main[0].metadata[0].annotations, {})
}
