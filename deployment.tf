resource "kubernetes_deployment" "main" {
  metadata {
    name      = local.resource_name
    namespace = var.namespace

    annotations = {}

    labels = {
      app = local.resource_name
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = local.resource_name
      }
    }

    template {
      metadata {
        labels = {
          app = local.resource_name
        }
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
