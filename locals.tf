locals {
  resource_name = "${var.deployment.prefix}-${var.deployment.name}"

  base_labels = {
    app = local.resource_name
  }

  labels = merge(local.base_labels, var.deployment.labels)

  image_repository = var.deployment.create_ecr ? aws_ecr_repository.main[0].repository_url : (var.deployment.image_repository != "" ? "${var.deployment.image_repository}:" : "")

  svc_labels = merge(local.base_labels, var.deployment.svc_labels)
}