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
          args    = var.args
          command = var.command
          dynamic "env" {
            for_each = var.env
            content {
              name       = env.value
              value      = lookup(env.value, "value", null)
              value_from = lookup(env.value, "value_from", null)
            }
          }
          dynamic "env_from" {
            for_each = var.env_from
            content {
              dynamic "config_map_ref" {
                for_each = lookup(env_from.value, "config_map_ref", [])
                content {
                  name     = lookup(config_map_ref.value, "name", null)
                  optional = lookup(config_map_ref.value, "name", null)
                }
              }
              prefix = lookup(env_from.value, "prefix", null)
              dynamic "secret_ref" {
                for_each = lookup(env_from.value, "secret_ref", [])
                content {
                  name     = lookup(secret_ref.value, "name", null)
                  optional = lookup(secret_ref.value, "name", null)
                }
              }
            }
          }
          name              = local.resource_name
          image             = local.image
          image_pull_policy = var.image_pull_policy
          dynamic "liveness_probe" {
            for_each = var.liveness_probe
            content {
              dynamic "exec" {
                for_each = lookup(liveness_probe.value, "exec", [])
                content {
                  command = lookup(exec.value, "name", null)
                }
              }
              failure_threshold = lookup(liveness_probe.value, "failure_threshold", [])
              dynamic "http_get" {
                for_each = lookup(liveness_probe.value, "http_get", [])
                content {
                  host = lookup(http_get.value, "host", null)
                  dynamic "http_header" {
                    for_each = lookup(http_get.value, "http_header", [])
                    content {
                      name  = lookup(http_header.value, "name", null)
                      value = lookup(http_header.value, "value", null)
                    }
                  }
                  path   = lookup(http_get.value, "path", null)
                  port   = lookup(http_get.value, "port", null)
                  scheme = lookup(http_get.value, "scheme", null)
                }
              }
              initial_delay_seconds = lookup(liveness_probe.value, "initial_delay_seconds", null)
              period_seconds        = lookup(liveness_probe.value, "period_seconds", null)
              success_threshold     = lookup(liveness_probe.value, "success_threshold", null)
              dynamic "tcp_socket" {
                for_each = lookup(liveness_probe.value, "tcp_socket", [])
                content {
                  port = lookup(tcp_socket.value, "port", null)
                }
              }
              timeout_seconds = lookup(liveness_probe.value, "timeout_seconds", null)
            }
          }
          dynamic "volume_mount" {
            for_each = var.volume_mount
            content {
              mount_path        = lookup(volume_mount.value, "mount_path", null)
              name              = lookup(volume_mount.value, "name", null)
              read_only         = lookup(volume_mount.value, "read_only", null)
              sub_path          = lookup(volume_mount.value, "sub_path", null)
              mount_propagation = lookup(volume_mount.value, "mount_propagation", null)
            }
          }
          working_dir = var.working_dir

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
