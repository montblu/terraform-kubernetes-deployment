variable "deployment" {
  description = "Kubernetes deployment configuration"
  type = object({
    name                      = string
    prefix                    = string
    namespace                 = string
    service_account_name      = optional(string, null)
    deployment_annotations    = optional(map(string), {})
    template_annotations      = optional(map(string), {})
    labels                    = optional(map(string), {})
    replicas                  = optional(number, 1)
    progress_deadline_seconds = optional(number, 600)
    enable_service_links      = optional(bool, true)
    affinity = optional(list(
      object({
        node_affinity     = optional(list(map(any)), [])
        pod_affinity      = optional(list(map(any)), [])
        pod_anti_affinity = optional(list(map(any)), [])
      })
    ), [])
    node_selector             = optional(map(string), {})
    toleration = optional(list(
      object({
        effect             = optional(string, "") # allowed values are "", NoSchedule, PreferNoSchedule and NoExecute.
        key                = optional(string, "")
        operator           = optional(string, "Equal") # Valid operators are Exists and Equal
        toleration_seconds = optional(string, "")
        value              = optional(string, "")
      })
    ), [])
    volumes          = optional(any, [])
    wait_for_rollout = optional(bool, false)
    host_aliases = optional(list(object({
      ip        = optional(string, "")
      hostnames = optional(list(string), [])
    })), [])

    init_container = optional(list(object({
      name              = string
      image_repository  = optional(string, "")
      image_tag         = optional(string, "")
      image_pull_policy = optional(string, "IfNotPresent")
      env_from          = optional(any, [])
      volume_mount      = optional(list(map(any)), [])
      command           = optional(list(string), [])
      args              = optional(list(string), [])
      working_dir       = optional(string)
      env               = optional(list(map(any)), [])
      resource_limits   = optional(object({ cpu = optional(string), memory = optional(string) }), null)
      resource_requests = optional(object({ cpu = optional(string), memory = optional(string) }), null)
      lifecycle         = optional(any, [])
      security_context  = optional(any, [])
    })), [])

    containers = list(object({
      name              = string
      image_tag         = optional(string, "")
      image_repository  = optional(string, "")
      image_pull_policy = optional(string, "IfNotPresent")
      env_from          = optional(any, [])
      volume_mount      = optional(list(map(any)), [])
      command           = optional(list(string), [])
      args              = optional(list(string), [])
      working_dir       = optional(string)
      env               = optional(list(map(any)), [])
      resource_limits   = optional(object({ cpu = optional(string), memory = optional(string) }), null)
      resource_requests = optional(object({ cpu = optional(string), memory = optional(string) }), null)
      lifecycle         = optional(any, [])
      startup_probe = optional(list(object({
        failure_threshold     = optional(number)
        initial_delay_seconds = optional(number)
        period_seconds        = optional(number)
        success_threshold     = optional(number)
        timeout_seconds       = optional(number)
        exec = optional(list(object({
          command = optional(list(string))
        })), [])
        http_get = optional(list(object({
          host   = optional(string)
          path   = optional(string)
          port   = optional(number)
          scheme = optional(string)
          http_header = optional(list(object({
            name  = optional(string)
            value = optional(string)
          })), [])
        })), [])
        tcp_socket = optional(list(object({
          port = optional(number)
        })), [])
      })), [])
      liveness_probe = optional(list(object({
        failure_threshold     = optional(number)
        initial_delay_seconds = optional(number)
        period_seconds        = optional(number)
        success_threshold     = optional(number)
        timeout_seconds       = optional(number)
        exec = optional(list(object({
          command = optional(list(string))
        })), [])
        http_get = optional(list(object({
          host   = optional(string)
          path   = optional(string)
          port   = optional(number)
          scheme = optional(string)
          http_header = optional(list(object({
            name  = optional(string)
            value = optional(string)
          })), [])
        })), [])
        tcp_socket = optional(list(object({
          port = optional(number)
        })), [])
      })), [])
      readiness_probe = optional(list(object({
        failure_threshold     = optional(number)
        initial_delay_seconds = optional(number)
        period_seconds        = optional(number)
        success_threshold     = optional(number)
        timeout_seconds       = optional(number)
        exec = optional(list(object({
          command = optional(list(string))
        })), [])
        http_get = optional(list(object({
          host   = optional(string)
          path   = optional(string)
          port   = optional(number)
          scheme = optional(string)
          http_header = optional(list(object({
            name  = optional(string)
            value = optional(string)
          })), [])
        })), [])
        tcp_socket = optional(list(object({
          port = optional(number)
        })), [])
      })), [])
      security_context = optional(any, [])
    }))

    termination_grace_period_seconds = optional(number)
    priority_class_name              = optional(string)

    create = optional(bool, true)

    pdb_create          = optional(bool, true)
    pdb_max_unavailable = optional(number, 1)
    pdb_min_available   = optional(number)

    create_svc         = optional(bool, true)
    create_svc_monitor = optional(bool, false)
    svc_annotations    = optional(map(any), {})
    svc_labels         = optional(map(string), {})
    svc_ports = optional(list(object({
      name        = optional(string)
      protocol    = optional(string, "TCP")
      port        = optional(number, 80)
      target_port = optional(number)
    })), [{ name = "http" }])
    svc_type                = optional(string, "ClusterIP")
    svc_load_balancer_class = optional(string)
    svc_monitor_port        = optional(string)
    svc_monitor_path        = optional(string, "/metrics")
  })
}

variable "strategy_type" {
  type        = string
  description = "Type of deployment. Can be 'Recreate' or 'RollingUpdate'."
  default     = "RollingUpdate"
}

variable "strategy_rolling_update" {
  type        = list(any)
  description = "Rolling update config params. Present only if type = RollingUpdate."
  default     = []
}
