locals {
  resource_name = "${var.deployment.prefix}-${var.deployment.name}"

  base_labels = {
    app = local.resource_name
  }

  labels = merge(local.base_labels, var.deployment.labels)

  general_image_repository = var.deployment.create_ecr ? aws_ecr_repository.main[0].repository_url : (var.image_repository != "" ? var.image_repository : "")

  svc_labels = merge(local.base_labels, var.deployment.svc_labels)
}

################################################################################
# ECR Repository
################################################################################
resource "aws_ecr_repository" "main" {
  count = var.deployment.create_ecr ? 1 : 0

  name = local.resource_name

  image_scanning_configuration {
    scan_on_push = var.deployment.ecr_scan_on_push
  }

  encryption_configuration {
    encryption_type = var.deployment.ecr_encryption_type
  }

}

resource "aws_ecr_lifecycle_policy" "main" {
  count = var.deployment.create_ecr ? 1 : 0

  repository = aws_ecr_repository.main[0].name
  policy     = var.ecr_lifecycle_policy
}

# allow pull from all other accounts
data "aws_iam_policy_document" "main" {
  count = var.deployment.create_ecr && length(var.ecr_allowed_aws_accounts) > 0 ? 1 : 0

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
  count = var.deployment.create_ecr && length(var.ecr_allowed_aws_accounts) > 0 ? 1 : 0

  repository = aws_ecr_repository.main[0].name
  policy     = data.aws_iam_policy_document.main[0].json
}

################################################################################
# Kubernetes Deployment
################################################################################
resource "kubernetes_deployment" "main" {
  metadata {
    name      = local.resource_name
    namespace = var.deployment.namespace

    annotations = var.deployment.annotations
    labels      = local.labels
  }

  spec {
    replicas = var.deployment.replicas
    strategy {
      type = var.strategy_type

      dynamic "rolling_update" {
        for_each = var.strategy_type == "RollingUpdate" ? var.strategy_rolling_update : []
        content {
          max_surge       = lookup(rolling_update.value, "max_surge", "")
          max_unavailable = lookup(rolling_update.value, "max_unavailable", "")
        }
      }
    }

    selector {
      match_labels = local.labels
    }

    template {
      metadata {
        labels = local.labels
      }
      spec {
        dynamic "affinity" {
          for_each = var.deployment.affinity
          content {
            dynamic "node_affinity" {
              for_each = can(affinity.value["node_affinity"]) ? affinity.value["node_affinity"] : []
              content {
                dynamic "required_during_scheduling_ignored_during_execution" {
                  for_each = can(node_affinity.value["required_during_scheduling_ignored_during_execution"]) ? node_affinity.value["required_during_scheduling_ignored_during_execution"] : []
                  content {
                    dynamic "node_selector_term" {
                      for_each = can(required_during_scheduling_ignored_during_execution.value["node_selector_term"]) ? required_during_scheduling_ignored_during_execution.value["node_selector_term"] : []
                      content {
                        dynamic "match_expressions" {
                          for_each = can(node_selector_term.value["match_expressions"]) ? node_selector_term.value["match_expressions"] : []
                          content {
                            key      = can(match_expressions.value["key"]) ? match_expressions.value["key"] : null
                            operator = can(match_expressions.value["operator"]) ? match_expressions.value["operator"] : null
                            values   = can(match_expressions.value["values"]) ? match_expressions.value["values"] : null
                          }
                        }
                      }
                    }
                  }
                }
                dynamic "preferred_during_scheduling_ignored_during_execution" {
                  for_each = can(node_affinity.value["preferred_during_scheduling_ignored_during_execution"]) ? node_affinity.value["preferred_during_scheduling_ignored_during_execution"] : []
                  content {
                    dynamic "preference" {
                      for_each = can(preferred_during_scheduling_ignored_during_execution.value["preference"]) ? preferred_during_scheduling_ignored_during_execution.value["preference"] : []
                      content {
                        dynamic "match_expressions" {
                          for_each = can(preference.value["match_expressions"]) ? preference.value["match_expressions"] : []
                          content {
                            key      = can(match_expressions.value["key"]) ? match_expressions.value["key"] : null
                            operator = can(match_expressions.value["operator"]) ? match_expressions.value["operator"] : null
                            values   = can(match_expressions.value["values"]) ? match_expressions.value["values"] : null
                          }
                        }
                      }
                    }

                    weight = can(preferred_during_scheduling_ignored_during_execution.value["weight"]) ? preferred_during_scheduling_ignored_during_execution.value["weight"] : null
                  }
                }
              }
            }
            dynamic "pod_affinity" {
              for_each = can(affinity.value["pod_affinity"]) ? affinity.value["pod_affinity"] : []
              content {
                dynamic "required_during_scheduling_ignored_during_execution" {
                  for_each = can(pod_affinity.value["required_during_scheduling_ignored_during_execution"]) ? pod_affinity.value["required_during_scheduling_ignored_during_execution"] : []
                  content {
                    dynamic "label_selector" {
                      for_each = can(required_during_scheduling_ignored_during_execution.value["label_selector"]) ? required_during_scheduling_ignored_during_execution.value["label_selector"] : []
                      content {
                        dynamic "match_expressions" {
                          for_each = can(label_selector.value["match_expressions"]) ? label_selector.value["match_expressions"] : []
                          content {
                            key      = can(match_expressions.value["key"]) ? match_expressions.value["key"] : null
                            operator = can(match_expressions.value["operator"]) ? match_expressions.value["operator"] : null
                            values   = can(match_expressions.value["values"]) ? match_expressions.value["values"] : null
                          }
                        }
                      }
                    }
                    namespaces   = can(required_during_scheduling_ignored_during_execution.value["namespaces"]) ? required_during_scheduling_ignored_during_execution.value["namespaces"] : null
                    topology_key = can(required_during_scheduling_ignored_during_execution.value["topology_key"]) ? required_during_scheduling_ignored_during_execution.value["topology_key"] : null
                  }
                }
                dynamic "preferred_during_scheduling_ignored_during_execution" {
                  for_each = can(pod_affinity.value["preferred_during_scheduling_ignored_during_execution"]) ? pod_affinity.value["preferred_during_scheduling_ignored_during_execution"] : []
                  content {
                    dynamic "pod_affinity_term" {
                      for_each = can(preferred_during_scheduling_ignored_during_execution.value["pod_affinity_term"]) ? preferred_during_scheduling_ignored_during_execution.value["pod_affinity_term"] : []
                      content {
                        dynamic "label_selector" {
                          for_each = can(pod_affinity_term.value["label_selector"]) ? pod_affinity_term.value["label_selector"] : []
                          content {
                            dynamic "match_expressions" {
                              for_each = can(label_selector.value["match_expressions"]) ? label_selector.value["match_expressions"] : []
                              content {
                                key      = can(match_expressions.value["key"]) ? match_expressions.value["key"] : null
                                operator = can(match_expressions.value["operator"]) ? match_expressions.value["operator"] : null
                                values   = can(match_expressions.value["values"]) ? match_expressions.value["values"] : null
                              }
                            }
                          }
                        }
                        namespaces   = can(pod_affinity_term.value["namespaces"]) ? pod_affinity_term.value["namespaces"] : null
                        topology_key = can(pod_affinity_term.value["topology_key"]) ? pod_affinity_term.value["topology_key"] : null
                      }
                    }
                    weight = can(preferred_during_scheduling_ignored_during_execution.value["weight"]) ? preferred_during_scheduling_ignored_during_execution.value["weight"] : null
                  }
                }
              }
            }
            dynamic "pod_anti_affinity" {
              for_each = can(affinity.value["pod_anti_affinity"]) ? affinity.value["pod_anti_affinity"] : []
              content {
                dynamic "required_during_scheduling_ignored_during_execution" {
                  for_each = can(pod_anti_affinity.value["required_during_scheduling_ignored_during_execution"]) ? pod_anti_affinity.value["required_during_scheduling_ignored_during_execution"] : []
                  content {
                    dynamic "label_selector" {
                      for_each = can(required_during_scheduling_ignored_during_execution.value["label_selector"]) ? required_during_scheduling_ignored_during_execution.value["label_selector"] : []
                      content {
                        dynamic "match_expressions" {
                          for_each = can(label_selector.value["match_expressions"]) ? label_selector.value["match_expressions"] : []
                          content {
                            key      = can(match_expressions.value["key"]) ? match_expressions.value["key"] : null
                            operator = can(match_expressions.value["operator"]) ? match_expressions.value["operator"] : null
                            values   = can(match_expressions.value["values"]) ? match_expressions.value["values"] : null
                          }
                        }
                      }
                    }
                    namespaces   = can(required_during_scheduling_ignored_during_execution.value["namespaces"]) ? required_during_scheduling_ignored_during_execution.value["namespaces"] : null
                    topology_key = can(required_during_scheduling_ignored_during_execution.value["topology_key"]) ? required_during_scheduling_ignored_during_execution.value["topology_key"] : null
                  }
                }
                dynamic "preferred_during_scheduling_ignored_during_execution" {
                  for_each = can(pod_anti_affinity.value["preferred_during_scheduling_ignored_during_execution"]) ? pod_anti_affinity.value["preferred_during_scheduling_ignored_during_execution"] : []
                  content {
                    dynamic "pod_affinity_term" {
                      for_each = can(preferred_during_scheduling_ignored_during_execution.value["pod_affinity_term"]) ? preferred_during_scheduling_ignored_during_execution.value["pod_affinity_term"] : []
                      content {
                        dynamic "label_selector" {
                          for_each = can(pod_affinity_term.value["label_selector"]) ? pod_affinity_term.value["label_selector"] : []
                          content {
                            dynamic "match_expressions" {
                              for_each = can(label_selector.value["match_expressions"]) ? label_selector.value["match_expressions"] : []
                              content {
                                key      = can(match_expressions.value["key"]) ? match_expressions.value["key"] : null
                                operator = can(match_expressions.value["operator"]) ? match_expressions.value["operator"] : null
                                values   = can(match_expressions.value["values"]) ? match_expressions.value["values"] : null
                              }
                            }
                          }
                        }
                        namespaces   = can(pod_affinity_term.value["namespaces"]) ? pod_affinity_term.value["namespaces"] : null
                        topology_key = can(pod_affinity_term.value["topology_key"]) ? pod_affinity_term.value["topology_key"] : null
                      }
                    }
                    weight = can(preferred_during_scheduling_ignored_during_execution.value["weight"]) ? preferred_during_scheduling_ignored_during_execution.value["weight"] : null
                  }
                }
              }
            }
          }
        }

        dynamic "host_aliases" {
          for_each = var.deployment.host_aliases

          content {
            ip        = host_aliases.value.ip
            hostnames = host_aliases.value.hostnames
          }
        }

        dynamic "init_container" {
          for_each = var.deployment.init_container
          content {
            name              = "${local.resource_name}-init"
            image             = init_container.value.image_repository != "" ? "${init_container.value.image_repository}:${init_container.value.image_tag}" : "${local.general_image_repository}:${init_container.value.image_tag}"
            image_pull_policy = init_container.value.image_pull_policy
            args              = init_container.value.args
            command           = init_container.value.command
            working_dir       = init_container.value.working_dir
            dynamic "env" {
              for_each = init_container.value["env"]
              content {
                name  = can(env.value["name"]) ? env.value["name"] : null
                value = can(env.value["value"]) ? env.value["value"] : null
                dynamic "value_from" {
                  for_each = can(env.value["value_from"]) ? env.value["value_from"] : []
                  content {
                    dynamic "config_map_key_ref" {
                      for_each = can(value_from.value["config_map_key_ref"]) ? value_from.value["config_map_key_ref"] : []
                      content {
                        key      = can(config_map_key_ref.value["key"]) ? config_map_key_ref.value["key"] : null
                        name     = can(config_map_key_ref.value["name"]) ? config_map_key_ref.value["name"] : null
                        optional = can(config_map_key_ref.value["optional"]) ? config_map_key_ref.value["optional"] : null
                      }
                    }
                    dynamic "field_ref" {
                      for_each = can(value_from.value["field_ref"]) ? value_from.value["field_ref"] : []
                      content {
                        api_version = can(field_ref.value["api_version"]) ? field_ref.value["api_version"] : null
                        field_path  = can(field_ref.value["field_path"]) ? field_ref.value["field_path"] : null
                      }
                    }
                    dynamic "resource_field_ref" {
                      for_each = can(value_from.value["resource_field_ref"]) ? value_from.value["resource_field_ref"] : []
                      content {
                        container_name = can(resource_field_ref.value["container_name"]) ? resource_field_ref.value["container_name"] : null
                        resource       = can(resource_field_ref.value["resource"]) ? resource_field_ref.value["resource"] : null
                        divisor        = can(resource_field_ref.value["divisor"]) ? resource_field_ref.value["divisor"] : null
                      }
                    }
                    dynamic "secret_key_ref" {
                      for_each = can(value_from.value["secret_key_ref"]) ? value_from.value["secret_key_ref"] : []
                      content {
                        key      = can(secret_key_ref.value["key"]) ? secret_key_ref.value["key"] : null
                        name     = can(secret_key_ref.value["name"]) ? secret_key_ref.value["name"] : null
                        optional = can(secret_key_ref.value["optional"]) ? secret_key_ref.value["optional"] : null
                      }
                    }
                  }
                }
              }
            }
            dynamic "env_from" {
              for_each = can(init_container.value["env_from"]) ? init_container.value["env_from"] : []
              content {
                dynamic "config_map_ref" {
                  for_each = can(env_from.value["config_map_ref"]) ? env_from.value["config_map_ref"] : []
                  content {
                    name     = can(config_map_ref.value["name"]) ? config_map_ref.value["name"] : null
                    optional = can(config_map_ref.value["optional"]) ? config_map_ref.value["optional"] : null
                  }
                }
                prefix = can(env_from.value["prefix"]) ? env_from.value["prefix"] : null
                dynamic "secret_ref" {
                  for_each = can(env_from.value["secret_ref"]) ? env_from.value["secret_ref"] : []
                  content {
                    name     = can(secret_ref.value["name"]) ? secret_ref.value["name"] : null
                    optional = can(secret_ref.value["optional"]) ? secret_ref.value["optional"] : null
                  }
                }
              }
            }

            dynamic "volume_mount" {
              for_each = can(init_container.value["volume_mount"]) ? init_container.value["volume_mount"] : []
              content {
                mount_path        = can(volume_mount.value["mount_path"]) ? volume_mount.value["mount_path"] : null
                name              = can(volume_mount.value["name"]) ? volume_mount.value["name"] : null
                read_only         = can(volume_mount.value["read_only"]) ? volume_mount.value["read_only"] : null
                sub_path          = can(volume_mount.value["sub_path"]) ? volume_mount.value["sub_path"] : null
                mount_propagation = can(volume_mount.value["mount_propagation"]) ? volume_mount.value["mount_propagation"] : null
              }
            }

            resources {
              limits   = init_container.value["resource_limits"]
              requests = init_container.value["resource_requests"]
            }
          }
        }

        dynamic "container" {
          for_each = var.deployment.containers
          content {
            name              = container.value["name"]
            image             = container.value.image_repository != "" ? "${container.value.image_repository}:${container.value.image_tag}" : "${local.general_image_repository}:${container.value.image_tag}"
            image_pull_policy = container.value["image_pull_policy"]
            args              = container.value["args"]
            command           = container.value["command"]
            working_dir       = container.value["working_dir"]

            dynamic "env" {
              for_each = container.value["env"]
              content {
                name  = env.value["name"]
                value = env.value["value"]

                dynamic "value_from" {
                  for_each = can(env.value["value_from"]) ? env.value["value_from"] : []
                  content {
                    dynamic "config_map_key_ref" {
                      for_each = can(value_from.value["config_map_key_ref"]) ? value_from.value["config_map_key_ref"] : []
                      content {
                        key      = config_map_key_ref.value["key"]
                        name     = config_map_key_ref.value["name"]
                        optional = config_map_key_ref.value["optional"]
                      }
                    }

                    dynamic "field_ref" {
                      for_each = can(value_from.value["field_ref"]) ? value_from.value["field_ref"] : []
                      content {
                        api_version = field_ref.value["api_version"]
                        field_path  = field_ref.value["field_path"]
                      }
                    }

                    dynamic "resource_field_ref" {
                      for_each = can(value_from.value["resource_field_ref"]) ? value_from.value["resource_field_ref"] : []
                      content {
                        container_name = resource_field_ref.value["container_name"]
                        resource       = resource_field_ref.value["resource"]
                        divisor        = resource_field_ref.value["divisor"]
                      }
                    }

                    dynamic "secret_key_ref" {
                      for_each = can(value_from.value["secret_key_ref"]) ? value_from.value["secret_key_ref"] : []
                      content {
                        key      = secret_key_ref.value["key"]
                        name     = secret_key_ref.value["name"]
                        optional = secret_key_ref.value["optional"]
                      }
                    }
                  }
                }
              }
            }

            dynamic "env_from" {
              for_each = container.value["env_from"]
              content {
                dynamic "config_map_ref" {
                  for_each = can(env_from.value["config_map_ref"]) ? env_from.value["config_map_ref"] : []
                  content {
                    name     = can(config_map_ref.value["name"]) ? config_map_ref.value["name"] : []
                    optional = can(config_map_ref.value["optional"]) ? config_map_ref.value["optional"] : []
                  }
                }

                prefix = can(env_from.value["prefix"]) ? env_from.value["prefix"] : []

                dynamic "secret_ref" {
                  for_each = can(env_from.value["secret_ref"]) ? env_from.value["secret_ref"] : []
                  content {
                    name     = can(secret_ref.value["name"]) ? secret_ref.value["name"] : []
                    optional = can(secret_ref.value["optional"]) ? secret_ref.value["optional"] : []
                  }
                }
              }
            }

            dynamic "liveness_probe" {
              for_each = can(container.value["liveness_probe"]) ? container.value["liveness_probe"] : []
              content {

                failure_threshold     = can(liveness_probe.value["failure_threshold"]) ? liveness_probe.value["failure_threshold"] : null
                initial_delay_seconds = can(liveness_probe.value["initial_delay_seconds"]) ? liveness_probe.value["initial_delay_seconds"] : null
                period_seconds        = can(liveness_probe.value["period_seconds"]) ? liveness_probe.value["period_seconds"] : null
                success_threshold     = can(liveness_probe.value["success_threshold"]) ? liveness_probe.value["success_threshold"] : null
                timeout_seconds       = can(liveness_probe.value["timeout_seconds"]) ? liveness_probe.value["timeout_seconds"] : null
                dynamic "exec" {
                  for_each = can(liveness_probe.value["exec"]) ? liveness_probe.value["exec"] : []
                  content {
                    command = can(exec.value["command"]) ? exec.value["command"] : null
                  }
                }
                dynamic "http_get" {
                  for_each = can(liveness_probe.value["http_get"]) ? liveness_probe.value["http_get"] : []
                  content {
                    host   = can(http_get.value["host"]) ? http_get.value["host"] : null
                    path   = can(http_get.value["path"]) ? http_get.value["path"] : null
                    port   = can(http_get.value["port"]) ? http_get.value["port"] : null
                    scheme = can(http_get.value["scheme"]) ? http_get.value["scheme"] : null

                    dynamic "http_header" {
                      for_each = can(http_get.value["http_header"]) ? http_get.value["http_header"] : []
                      content {
                        name  = can(http_header.value["name"]) ? http_header.value["name"] : null
                        value = can(http_header.value["value"]) ? http_header.value["value"] : null
                      }
                    }
                  }
                }

                dynamic "tcp_socket" {
                  for_each = can(liveness_probe.value["tcp_socket"]) ? liveness_probe.value["tcp_socket"] : []
                  content {
                    port = can(tcp_socket.value["port"]) ? tcp_socket.value["port"] : null
                  }
                }
              }
            }

            dynamic "readiness_probe" {
              for_each = can(container.value["readiness_probe"]) ? container.value["readiness_probe"] : []
              content {

                failure_threshold     = can(readiness_probe.value["failure_threshold"]) ? readiness_probe.value["failure_threshold"] : null
                initial_delay_seconds = can(readiness_probe.value["initial_delay_seconds"]) ? readiness_probe.value["initial_delay_seconds"] : null
                period_seconds        = can(readiness_probe.value["period_seconds"]) ? readiness_probe.value["period_seconds"] : null
                success_threshold     = can(readiness_probe.value["success_threshold"]) ? readiness_probe.value["success_threshold"] : null
                timeout_seconds       = can(readiness_probe.value["timeout_seconds"]) ? readiness_probe.value["timeout_seconds"] : null
                dynamic "exec" {
                  for_each = can(readiness_probe.value["exec"]) ? readiness_probe.value["exec"] : []
                  content {
                    command = can(exec.value["command"]) ? exec.value["command"] : null
                  }
                }
                dynamic "http_get" {
                  for_each = can(readiness_probe.value["http_get"]) ? readiness_probe.value["http_get"] : []
                  content {
                    host   = can(http_get.value["host"]) ? http_get.value["host"] : null
                    path   = can(http_get.value["path"]) ? http_get.value["path"] : null
                    port   = can(http_get.value["port"]) ? http_get.value["port"] : null
                    scheme = can(http_get.value["scheme"]) ? http_get.value["scheme"] : null

                    dynamic "http_header" {
                      for_each = can(http_get.value["http_header"]) ? http_get.value["http_header"] : []
                      content {
                        name  = can(http_header.value["name"]) ? http_header.value["name"] : null
                        value = can(http_header.value["value"]) ? http_header.value["value"] : null
                      }
                    }
                  }
                }
                dynamic "tcp_socket" {
                  for_each = can(readiness_probe.value["tcp_socket"]) ? readiness_probe.value["tcp_socket"] : []
                  content {
                    port = can(tcp_socket.value["port"]) ? tcp_socket.value["port"] : null
                  }
                }
              }
            }

            dynamic "volume_mount" {
              for_each = can(container.value["volume_mount"]) ? container.value["volume_mount"] : []
              content {
                mount_path        = can(volume_mount.value["mount_path"]) ? volume_mount.value["mount_path"] : null
                name              = can(volume_mount.value["name"]) ? volume_mount.value["name"] : null
                read_only         = can(volume_mount.value["read_only"]) ? volume_mount.value["read_only"] : null
                sub_path          = can(volume_mount.value["sub_path"]) ? volume_mount.value["sub_path"] : null
                mount_propagation = can(volume_mount.value["mount_propagation"]) ? volume_mount.value["mount_propagation"] : null
              }
            }

            resources {
              limits   = container.value["resource_limits"]
              requests = container.value["resource_requests"]
            }
          }
        }


        dynamic "volume" {
          for_each = var.deployment.volumes

          content {
            name = can(volume.value["name"]) ? volume.value["name"] : null

            dynamic "secret" {
              for_each = can(volume.value["secret"]) ? volume.value["secret"] : []

              content {
                default_mode = can(secret.value["default_mode"]) ? secret.value["default_mode"] : null
                optional     = can(secret.value["optional"]) ? secret.value["optional"] : null
                secret_name  = can(secret.value["secret_name"]) ? secret.value["secret_name"] : null

                dynamic "items" {
                  for_each = can(secret.value["items"]) ? secret.value["items"] : []
                  content {
                    key  = can(items.value["key"]) ? items.value["key"] : null
                    mode = can(items.value["mode"]) ? items.value["mode"] : null
                    path = can(items.value["path"]) ? items.value["path"] : null
                  }
                }
              }
            }

            dynamic "aws_elastic_block_store" {
              for_each = can(volume.value["aws_elastic_block_store"]) ? volume.value["aws_elastic_block_store"] : []
              content {
                fs_type   = can(aws_elastic_block_store.value["fs_type"]) ? aws_elastic_block_store.value["fs_type"] : null
                partition = can(aws_elastic_block_store.value["partition"]) ? aws_elastic_block_store.value["partition"] : null
                read_only = can(aws_elastic_block_store.value["read_only"]) ? aws_elastic_block_store.value["read_only"] : null
                volume_id = can(aws_elastic_block_store.value["volume_id"]) ? aws_elastic_block_store.value["volume_id"] : null
              }
            }
            dynamic "config_map" {
              for_each = can(volume.value["config_map"]) ? volume.value["config_map"] : []
              content {
                default_mode = can(config_map.value["default_mode"]) ? config_map.value["default_mode"] : null
                dynamic "items" {
                  for_each = can(config_map.value["items"]) ? config_map.value["items"] : []
                  content {
                    key  = can(items.value["key"]) ? items.value["key"] : null
                    mode = can(items.value["mode"]) ? items.value["mode"] : null
                    path = can(items.value["path"]) ? items.value["path"] : null
                  }
                }
                optional = can(config_map.value["optional"]) ? config_map.value["optional"] : null
                name     = can(config_map.value["name"]) ? config_map.value["name"] : null
              }
            }
            dynamic "empty_dir" {
              for_each = can(volume.value["empty_dir"]) ? volume.value["empty_dir"] : []
              content {
                medium     = can(empty_dir.value["medium"]) ? empty_dir.value["medium"] : null
                size_limit = can(empty_dir.value["size_limit"]) ? empty_dir.value["size_limit"] : null
              }
            }
            dynamic "persistent_volume_claim" {
              for_each = can(volume.value["persistent_volume_claim"]) ? volume.value["persistent_volume_claim"] : []
              content {
                claim_name = can(persistent_volume_claim.value["claim_name"]) ? persistent_volume_claim.value["claim_name"] : null
                read_only  = can(persistent_volume_claim.value["read_only"]) ? persistent_volume_claim.value["read_only"] : null
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
      spec[0].template[0].spec[0].container[2].image,
    ]
  }

  wait_for_rollout = var.deployment.wait_for_rollout

  depends_on = [
    aws_ecr_lifecycle_policy.main
  ]
}

################################################################################
# Kubernetes Service
################################################################################
resource "kubernetes_service" "main" {
  count = var.deployment.create_svc ? 1 : 0

  metadata {
    annotations = var.deployment.svc_annotations
    name        = local.resource_name
    namespace   = var.deployment.namespace

    labels = local.svc_labels
  }

  spec {
    dynamic "port" {
      for_each = var.deployment.svc_ports
      content {
        name        = port.value["name"]
        protocol    = port.value["protocol"]
        port        = port.value["port"]
        target_port = port.value["target_port"] != null ? port.value["target_port"] : port.value["port"]
      }
    }

    selector = {
      app = local.resource_name
    }

    type                = var.deployment.svc_type
    load_balancer_class = var.deployment.svc_load_balancer_class
  }

  depends_on = [
    kubernetes_deployment.main
  ]
}

################################################################################
# ServiceMonitor (Prometheus-Operator)
################################################################################
resource "kubectl_manifest" "main" {
  count = var.deployment.create_svc && var.deployment.create_svc_monitor ? 1 : 0

  yaml_body = <<YAML
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: ${local.resource_name}
  namespace: ${var.deployment.namespace}
spec:
  selector:
    matchLabels:
      app: ${local.resource_name}
  endpoints:
    - path: "${var.deployment.svc_monitor_path}"
YAML

  depends_on = [
    kubernetes_service.main
  ]
}
