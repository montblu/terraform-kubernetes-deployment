output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = try(aws_ecr_repository.main.repository_url, "")
}