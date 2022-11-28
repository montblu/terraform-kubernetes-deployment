resource "kubernetes_deployment" "main" {
  metadata {
    name      = local.resource_name
    namespace = var.namespace

    annotations = {}

    labels = local.labes
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = local.labels
    }

    template {
      metadata {
        labels = local.labels
      }

      spec {
        volume {}

        container {
          name    = local.resource_name
          image   = variable.image
          command = local.command
        }
      }
    }
  }

  depends_on = [
    aws_ecr_lifecycle_policy.main
  ]
}
