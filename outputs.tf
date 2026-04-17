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

output "svc_name" {
  description = "The name of the service"
  value       = try(kubernetes_service.main[0].metadata[0].name, "")
}

output "svc_ports" {
  description = "The port(s) of the service"
  value       = try(kubernetes_service.main[0].spec[0].port, [])
}

output "svc_address" {
  description = "The address of the service within the cluster"
  value       = try("${kubernetes_service.main[0].metadata[0].name}.${kubernetes_service.main[0].metadata[0].namespace}.svc.cluster.local", "")
}
