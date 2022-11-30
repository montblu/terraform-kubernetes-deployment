resource "kubernetes_deployment" "main" {
  metadata {
    name      = local.resource_name
    namespace = var.namespace

    annotations = local.annotations
    labels      = local.labels
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
          args = var.args
          dynamic "env" {
            for_each = var.envs
            content {
              name       = block_device_mappings.value.device_name
              value      = lookup(block_device_mappings.value, "value", "")
              value_from = lookup(block_device_mappings.value, "value_from", "")
            }
          }
          command           = var.command
          name              = local.resource_name
          image             = local.image
          image_pull_policy = var.image_pull_policy
          working_dir       = var.working_dir

          resources {
            limits   = var.resource_limits
            requests = var.resource_requests
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      spec[0].template[0].metadata[0].annotations["reloader.stakater.com/last-reloaded-from"],
      spec[0].template[0].spec[0].container[0].image
    ]
  }

  wait_for_rollout = var.wait_for_rollout

  depends_on = [
    aws_ecr_lifecycle_policy.main
  ]
}
