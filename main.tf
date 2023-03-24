locals {
  resource_name = "${var.name_prefix}-${var.name}"

  default_ecr_lifecycle_policy = <<EOF
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

  ecr_lifecycle_policy = var.ecr_lifecycle_policy == "" ? local.default_ecr_lifecycle_policy : var.ecr_lifecycle_policy

  annotations = var.annotations
  default_labels = {
    app = local.resource_name
  }

  labels = merge(local.default_labels, var.labels)

  image = var.image == "" ? (var.ecr_create ? aws_ecr_repository.main[0].repository_url : "dummy") : var.image

  svc_labels = merge(local.default_labels, var.svc_labels)

  container = {
    args              = var.args
    command           = var.command
    env               = var.env
    env_from          = var.env_from
    name              = local.resource_name
    image             = local.image
    image_pull_policy = var.image_pull_policy
    liveness_probe    = var.liveness_probe
    readiness_probe   = var.readiness_probe
    volume_mount      = var.volume_mount
    working_dir       = var.working_dir
    resources = [
      {
        limits   = var.resource_limits
        requests = var.resource_requests
      }
    ]
  }

  containers = concat([local.container], var.additional_containers)
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
  policy     = local.ecr_lifecycle_policy

  depends_on = [
    aws_ecr_repository.main
  ]
}

# allow pull from all other accounts
data "aws_iam_policy_document" "main" {
  count = var.ecr_create ? 1 : 0

  dynamic "statement" {
    for_each = var.ecr_allowed_aws_accounts
    content {
      sid    = "Pull only for ${statement.value}"
      effect = "Allow"
      principals {
        type = "AWS"
        identifiers = [
          "arn:aws:iam::${statement.value}:root"
        ]
      }
      actions = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
      ]
    }
  }
}
resource "aws_ecr_repository_policy" "main" {
  count = var.ecr_create ? (length(var.ecr_allowed_aws_accounts) > 0 ? 1 : 0) : 0

  repository = aws_ecr_repository.main[0].name
  policy     = data.aws_iam_policy_document.main[0].json
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

        dynamic "affinity" {
          for_each = var.affinity
          content {
            dynamic "node_affinity" {
              for_each = lookup(affinity.value, "node_affinity", [])
              content {
                dynamic "required_during_scheduling_ignored_during_execution" {
                  for_each = lookup(node_affinity.value, "required_during_scheduling_ignored_during_execution", [])
                  content {
                    dynamic "node_selector_term" {
                      for_each = lookup(required_during_scheduling_ignored_during_execution.value, "node_selector_term", [])
                      content {
                        dynamic "match_expressions" {
                          for_each = lookup(node_selector_term.value, "match_expressions", [])
                          content {
                            key      = lookup(match_expressions.value, "key", null)
                            operator = lookup(match_expressions.value, "operator", null)
                            values   = lookup(match_expressions.value, "values", null)
                          }
                        }
                      }
                    }
                  }
                }
                dynamic "preferred_during_scheduling_ignored_during_execution" {
                  for_each = lookup(node_affinity.value, "preferred_during_scheduling_ignored_during_execution", [])
                  content {
                    dynamic "preference" {
                      for_each = lookup(preferred_during_scheduling_ignored_during_execution.value, "preference", [])
                      content {
                        dynamic "match_expressions" {
                          for_each = lookup(preference.value, "match_expressions", [])
                          content {
                            key      = lookup(match_expressions.value, "key", null)
                            operator = lookup(match_expressions.value, "operator", null)
                            values   = lookup(match_expressions.value, "values", null)
                          }
                        }
                      }
                    }

                    weight = lookup(preferred_during_scheduling_ignored_during_execution.value, "weight", null)
                  }
                }
              }
            }
            dynamic "pod_affinity" {
              for_each = lookup(affinity.value, "pod_affinity", [])
              content {
                dynamic "required_during_scheduling_ignored_during_execution" {
                  for_each = lookup(pod_affinity.value, "required_during_scheduling_ignored_during_execution", [])
                  content {
                    dynamic "label_selector" {
                      for_each = lookup(required_during_scheduling_ignored_during_execution.value, "label_selector", [])
                      content {
                        dynamic "match_expressions" {
                          for_each = lookup(label_selector.value, "match_expressions", [])
                          content {
                            key      = lookup(match_expressions.value, "key", null)
                            operator = lookup(match_expressions.value, "operator", null)
                            values   = lookup(match_expressions.value, "values", null)
                          }
                        }
                      }
                    }
                    namespaces   = lookup(required_during_scheduling_ignored_during_execution.value, "namespaces", null)
                    topology_key = lookup(required_during_scheduling_ignored_during_execution.value, "topology_key", null)
                  }
                }
                dynamic "preferred_during_scheduling_ignored_during_execution" {
                  for_each = lookup(pod_affinity.value, "preferred_during_scheduling_ignored_during_execution", [])
                  content {
                    dynamic "pod_affinity_term" {
                      for_each = lookup(preferred_during_scheduling_ignored_during_execution.value, "pod_affinity_term", [])
                      content {
                        dynamic "label_selector" {
                          for_each = lookup(pod_affinity_term.value, "label_selector", [])
                          content {
                            dynamic "match_expressions" {
                              for_each = lookup(label_selector.value, "match_expressions", [])
                              content {
                                key      = lookup(match_expressions.value, "key", null)
                                operator = lookup(match_expressions.value, "operator", null)
                                values   = lookup(match_expressions.value, "values", null)
                              }
                            }
                          }
                        }
                        namespaces   = lookup(pod_affinity_term.value, "namespaces", null)
                        topology_key = lookup(pod_affinity_term.value, "topology_key", null)
                      }
                    }
                    weight = lookup(preferred_during_scheduling_ignored_during_execution.value, "weight", null)
                  }
                }
              }
            }
            dynamic "pod_anti_affinity" {
              for_each = lookup(affinity.value, "pod_anti_affinity", [])
              content {
                dynamic "required_during_scheduling_ignored_during_execution" {
                  for_each = lookup(pod_anti_affinity.value, "required_during_scheduling_ignored_during_execution", [])
                  content {
                    dynamic "label_selector" {
                      for_each = lookup(required_during_scheduling_ignored_during_execution.value, "label_selector", [])
                      content {
                        dynamic "match_expressions" {
                          for_each = lookup(label_selector.value, "match_expressions", [])
                          content {
                            key      = lookup(match_expressions.value, "key", null)
                            operator = lookup(match_expressions.value, "operator", null)
                            values   = lookup(match_expressions.value, "values", null)
                          }
                        }
                      }
                    }
                    namespaces   = lookup(required_during_scheduling_ignored_during_execution.value, "namespaces", null)
                    topology_key = lookup(required_during_scheduling_ignored_during_execution.value, "topology_key", null)
                  }
                }
                dynamic "preferred_during_scheduling_ignored_during_execution" {
                  for_each = lookup(pod_anti_affinity.value, "preferred_during_scheduling_ignored_during_execution", [])
                  content {
                    dynamic "pod_affinity_term" {
                      for_each = lookup(preferred_during_scheduling_ignored_during_execution.value, "pod_affinity_term", [])
                      content {
                        dynamic "label_selector" {
                          for_each = lookup(pod_affinity_term.value, "label_selector", [])
                          content {
                            dynamic "match_expressions" {
                              for_each = lookup(label_selector.value, "match_expressions", [])
                              content {
                                key      = lookup(match_expressions.value, "key", null)
                                operator = lookup(match_expressions.value, "operator", null)
                                values   = lookup(match_expressions.value, "values", null)
                              }
                            }
                          }
                        }
                        namespaces   = lookup(pod_affinity_term.value, "namespaces", null)
                        topology_key = lookup(pod_affinity_term.value, "topology_key", null)
                      }
                    }
                    weight = lookup(preferred_during_scheduling_ignored_during_execution.value, "weight", null)
                  }
                }
              }
            }
          }
        }
        dynamic "init_container" {
          for_each = var.init_container
          content {
            args    = lookup(init_container.value, "args", null)
            command = lookup(init_container.value, "command", null)
            dynamic "env" {
              for_each = lookup(init_container.value, "env", [])
              content {
                name  = lookup(env.value, "name", null)
                value = lookup(env.value, "value", null)
                dynamic "value_from" {
                  for_each = lookup(env.value, "value_from", [])
                  content {
                    dynamic "config_map_key_ref" {
                      for_each = lookup(value_from.value, "config_map_key_ref", [])
                      content {
                        key      = lookup(config_map_key_ref.value, "key", null)
                        name     = lookup(config_map_key_ref.value, "name", null)
                        optional = lookup(config_map_key_ref.value, "optional", null)
                      }
                    }
                    dynamic "field_ref" {
                      for_each = lookup(value_from.value, "field_ref", [])
                      content {
                        api_version = lookup(field_ref.value, "api_version", null)
                        field_path  = lookup(field_ref.value, "field_path", null)
                      }
                    }
                    dynamic "resource_field_ref" {
                      for_each = lookup(value_from.value, "resource_field_ref", [])
                      content {
                        container_name = lookup(resource_field_ref.value, "container_name", null)
                        resource       = lookup(resource_field_ref.value, "resource", null)
                        divisor        = lookup(resource_field_ref.value, "divisor", null)
                      }
                    }
                    dynamic "secret_key_ref" {
                      for_each = lookup(value_from.value, "secret_key_ref", [])
                      content {
                        key      = lookup(secret_key_ref.value, "key", null)
                        name     = lookup(secret_key_ref.value, "name", null)
                        optional = lookup(secret_key_ref.value, "optional", null)
                      }
                    }
                  }
                }
              }
            }
            dynamic "env_from" {
              for_each = lookup(init_container.value, "env_from", [])
              content {
                dynamic "config_map_ref" {
                  for_each = lookup(env_from.value, "config_map_ref", [])
                  content {
                    name     = lookup(config_map_ref.value, "name", null)
                    optional = lookup(config_map_ref.value, "optional", null)
                  }
                }
                prefix = lookup(env_from.value, "prefix", null)
                dynamic "secret_ref" {
                  for_each = lookup(env_from.value, "secret_ref", [])
                  content {
                    name     = lookup(secret_ref.value, "name", null)
                    optional = lookup(secret_ref.value, "optional", null)
                  }
                }
              }
            }
            name              = lookup(init_container.value, "name", [])
            image             = lookup(init_container.value, "image", [])
            image_pull_policy = lookup(init_container.value, "image_pull_policy", [])
            dynamic "liveness_probe" {
              for_each = lookup(init_container.value, "liveness_probe", [])
              content {
                dynamic "exec" {
                  for_each = lookup(liveness_probe.value, "exec", [])
                  content {
                    command = lookup(exec.value, "name", null)
                  }
                }
                failure_threshold = lookup(liveness_probe.value, "failure_threshold", null)
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
              for_each = lookup(init_container.value, "volume_mount", [])
              content {
                mount_path        = lookup(volume_mount.value, "mount_path", null)
                name              = lookup(volume_mount.value, "name", null)
                read_only         = lookup(volume_mount.value, "read_only", null)
                sub_path          = lookup(volume_mount.value, "sub_path", null)
                mount_propagation = lookup(volume_mount.value, "mount_propagation", null)
              }
            }

            working_dir = lookup(init_container.value, "working_dir", [])

            dynamic "resources" {
              for_each = lookup(init_container.value, "resources", [])
              content {
                limits   = lookup(resources.value, "limits", {})
                requests = lookup(resources.value, "requests", {})
              }
            }
          }
        }
        dynamic "container" {
          for_each = local.containers
          content {
            args    = lookup(container.value, "args", null)
            command = lookup(container.value, "command", null)
            dynamic "env" {
              for_each = lookup(container.value, "env", [])
              content {
                name  = lookup(env.value, "name", null)
                value = lookup(env.value, "value", null)
                dynamic "value_from" {
                  for_each = lookup(env.value, "value_from", [])
                  content {
                    dynamic "config_map_key_ref" {
                      for_each = lookup(value_from.value, "config_map_key_ref", [])
                      content {
                        key      = lookup(config_map_key_ref.value, "key", null)
                        name     = lookup(config_map_key_ref.value, "name", null)
                        optional = lookup(config_map_key_ref.value, "optional", null)
                      }
                    }
                    dynamic "field_ref" {
                      for_each = lookup(value_from.value, "field_ref", [])
                      content {
                        api_version = lookup(field_ref.value, "api_version", null)
                        field_path  = lookup(field_ref.value, "field_path", null)
                      }
                    }
                    dynamic "resource_field_ref" {
                      for_each = lookup(value_from.value, "resource_field_ref", [])
                      content {
                        container_name = lookup(resource_field_ref.value, "container_name", null)
                        resource       = lookup(resource_field_ref.value, "resource", null)
                        divisor        = lookup(resource_field_ref.value, "divisor", null)
                      }
                    }
                    dynamic "secret_key_ref" {
                      for_each = lookup(value_from.value, "secret_key_ref", [])
                      content {
                        key      = lookup(secret_key_ref.value, "key", null)
                        name     = lookup(secret_key_ref.value, "name", null)
                        optional = lookup(secret_key_ref.value, "optional", null)
                      }
                    }
                  }
                }
              }
            }
            dynamic "env_from" {
              for_each = lookup(container.value, "env_from", [])
              content {
                dynamic "config_map_ref" {
                  for_each = lookup(env_from.value, "config_map_ref", [])
                  content {
                    name     = lookup(config_map_ref.value, "name", null)
                    optional = lookup(config_map_ref.value, "optional", null)
                  }
                }
                prefix = lookup(env_from.value, "prefix", null)
                dynamic "secret_ref" {
                  for_each = lookup(env_from.value, "secret_ref", [])
                  content {
                    name     = lookup(secret_ref.value, "name", null)
                    optional = lookup(secret_ref.value, "optional", null)
                  }
                }
              }
            }
            name              = lookup(container.value, "name", null)
            image             = lookup(container.value, "image", null)
            image_pull_policy = lookup(container.value, "image_pull_policy", null)
            dynamic "liveness_probe" {
              for_each = lookup(container.value, "liveness_probe", [])
              content {
                dynamic "exec" {
                  for_each = lookup(liveness_probe.value, "exec", [])
                  content {
                    command = lookup(exec.value, "name", null)
                  }
                }
                failure_threshold = lookup(liveness_probe.value, "failure_threshold", null)
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
            dynamic "readiness_probe" {
              for_each = lookup(container.value, "readiness_probe", [])
              content {
                dynamic "exec" {
                  for_each = lookup(readiness_probe.value, "exec", [])
                  content {
                    command = lookup(exec.value, "name", null)
                  }
                }
                failure_threshold = lookup(readiness_probe.value, "failure_threshold", null)
                dynamic "http_get" {
                  for_each = lookup(readiness_probe.value, "http_get", [])
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
                initial_delay_seconds = lookup(readiness_probe.value, "initial_delay_seconds", null)
                period_seconds        = lookup(readiness_probe.value, "period_seconds", null)
                success_threshold     = lookup(readiness_probe.value, "success_threshold", null)
                dynamic "tcp_socket" {
                  for_each = lookup(readiness_probe.value, "tcp_socket", [])
                  content {
                    port = lookup(tcp_socket.value, "port", null)
                  }
                }
                timeout_seconds = lookup(readiness_probe.value, "timeout_seconds", null)
              }
            }
            dynamic "volume_mount" {
              for_each = lookup(container.value, "volume_mount", [])
              content {
                mount_path        = lookup(volume_mount.value, "mount_path", null)
                name              = lookup(volume_mount.value, "name", null)
                read_only         = lookup(volume_mount.value, "read_only", null)
                sub_path          = lookup(volume_mount.value, "sub_path", null)
                mount_propagation = lookup(volume_mount.value, "mount_propagation", null)
              }
            }

            working_dir = lookup(container.value, "working_dir", null)

            dynamic "resources" {
              for_each = lookup(container.value, "resources", [])
              content {
                limits   = lookup(resources.value, "limits", null)
                requests = lookup(resources.value, "requests", null)
              }
            }
          }
        }
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
            name = lookup(volume.value, "name", null)
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
                  for_each = lookup(secret.value, "items", [])
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
      }
    }
  }

  lifecycle {
    ignore_changes = [
      spec[0].template[0].metadata[0].annotations["reloader.stakater.com/last-reloaded-from"],
      spec[0].template[0].spec[0].init_container[0].image,
      spec[0].template[0].spec[0].container[0].image,
      spec[0].template[0].spec[0].container[1].image,
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
    annotations = var.svc_annotations
    name        = local.resource_name
    namespace   = var.namespace

    labels = local.svc_labels
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

    type                = var.svc_type
    load_balancer_class = var.svc_load_balancer_class
  }

  depends_on = [
    kubernetes_deployment.main
  ]
}

################################################################################
# ServiceMonitor (Prometheus-Operator)
################################################################################
resource "kubectl_manifest" "main" {
  count = var.svc_create && var.svc_monitor_create ? 1 : 0

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
