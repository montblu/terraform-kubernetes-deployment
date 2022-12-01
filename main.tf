locals {
  resource_name = "${var.name_prefix}-${var.name}"

  annotations = var.annotations
  default_labels = {
    app = local.resource_name
  }

  labels = var.labels == {} ? local.default_labels : merge(local.default_labels, var.labels)

  image = var.image == "" ? (var.ecr_create ? aws_ecr_repository.main.repository_url : "dummy") : var.image
}


################################################################################
# ECR Repository
################################################################################
resource "aws_ecr_repository" "main" {
  count = var.ecr_create ? 1 : 0

  name = local.resource_name

  image_scanning_configuration {
    scan_on_push = var.ecr_scan_on_push
  }

  encryption_configuration {
    encryption_type = var.ecr_encryption_type
  }

  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "main" {
  count = var.ecr_create ? 1 : 0

  repository = aws_ecr_repository.main[0].name
  policy     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last ${var.ecr_number_of_images_to_keep} images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": ${var.ecr_number_of_images_to_keep}
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF

  depends_on = [
    aws_ecr_repository.main
  ]

  tags = var.tags
}

################################################################################
# Kubernetes Deployment
################################################################################
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
        dynamic "volume" {
          for_each = var.volume
          content {
            dynamic "aws_elastic_block_store" {
              for_each = lookup(volume.value, "aws_elastic_block_store", [])
              content {
                fs_type   = lookup(aws_elastic_block_store.value, "fs_type", null)
                partition = lookup(aws_elastic_block_store.value, "partition", null)
                read_only = lookup(aws_elastic_block_store.value, "read_only", null)
                volume_id = lookup(aws_elastic_block_store.value, "volume_id", null)
              }
            }
            dynamic "config_map" {
              for_each = lookup(volume.value, "config_map", [])
              content {
                default_mode = lookup(config_map.value, "default_mode", null)
                dynamic "items" {
                  for_each = lookup(config_map.value, "items", [])
                  content {
                    key  = lookup(items.value, "key", null)
                    mode = lookup(items.value, "mode", null)
                    path = lookup(items.value, "path", null)
                  }
                }
                optional = lookup(config_map.value, "optional", null)
                name     = lookup(config_map.value, "name", null)
              }
            }
            dynamic "empty_dir" {
              for_each = lookup(volume.value, "empty_dir", [])
              content {
                medium     = lookup(empty_dir.value, "medium", null)
                size_limit = lookup(empty_dir.value, "size_limit", null)
              }
            }
            name = lookup(volume.value, "name", [])
            dynamic "persistent_volume_claim" {
              for_each = lookup(volume.value, "persistent_volume_claim", [])
              content {
                claim_name = lookup(persistent_volume_claim.value, "claim_name", null)
                read_only  = lookup(persistent_volume_claim.value, "read_only", null)
              }
            }
            dynamic "secret" {
              for_each = lookup(volume.value, "secret", [])
              content {
                default_mode = lookup(secret.value, "default_mode", null)
                dynamic "items" {
                  for_each = lookup(config_map.value, "items", [])
                  content {
                    key  = lookup(items.value, "key", null)
                    mode = lookup(items.value, "mode", null)
                    path = lookup(items.value, "path", null)
                  }
                }
                optional    = lookup(secret.value, "optional", null)
                secret_name = lookup(secret.value, "secret_name", null)
              }
            }
          }
        }

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

################################################################################
# Kubernetes Service
################################################################################
resource "kubernetes_service" "main" {
  count = var.svc_create ? 1 : 0

  metadata {
    name      = local.resource_name
    namespace = var.namespace

    labels = {
      app = local.resource_name
    }
  }

  spec {
    port {
      port        = var.svc_port
      target_port = var.svc_port
      protocol    = var.svc_protocol
    }

    selector = {
      app = local.resource_name
    }

    type = var.svc_type
  }

  depends_on = [
    kubernetes_deployment.main
  ]
}

################################################################################
# ServiceMonitor (Prometheus-Operator)
################################################################################
resource "kubectl_manifest" "main" {
  count = var.svc_create ? (var.svc_monitor_create ? 1 : 0) : 0

  yaml_body = <<YAML
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: ${local.resource_name}
  namespace: ${var.namespace}
spec:
  selector:
    matchLabels:
      app: ${local.resource_name}
  endpoints:
    - path: "${var.svc_monitor_path}"
YAML

  depends_on = [
    kubernetes_service.main
  ]
}
