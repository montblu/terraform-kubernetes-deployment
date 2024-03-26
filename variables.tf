variable "deployment" {
  description = "Kubernetes deployment configuration"
  type = object({
    name              = string
    prefix            = optional(string)
    namespace         = string
    annotations       = optional(map(string), {})
    labels            = optional(map(string), {})
    replicas          = optional(number, 1)
    affinity          = optional(list(map(any)), [])
    volumes           = optional(any, [])
    resource_limits   = optional(object({ cpu = string, memory = string }))
    resource_requests = optional(object({ cpu = string, memory = string }))
    wait_for_rollout  = optional(bool, false)

    host_aliases = optional(list(object({
      ip        = optional(string, "")
      hostnames = optional(list(string), [])
    })), [])

    init_container = optional(list(object({
      name              = string
      image_repository  = optional(string, "")
      image             = optional(string, "")
      image_pull_policy = optional(string, "IfNotPresent")
      env_from          = optional(list(map(any)), [])
      volume_mount      = optional(list(map(any)), [])
      command           = optional(list(string), [])
      args              = optional(list(string), [])
      working_dir       = optional(string)
      env               = optional(list(map(any)), [])
    })), [])
    containers = list(object({
      name              = string
      image             = optional(string, "")
      image_repository  = optional(string, "")
      image_pull_policy = optional(string, "IfNotPresent")
      env_from          = optional(list(map(any)), [])
      volume_mount      = optional(list(map(any)), [])
      command           = optional(list(string), [])
      args              = optional(list(string), [])
      working_dir       = optional(string)
      env               = optional(list(map(any)), [])
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
    }))

    create_ecr          = optional(bool, false)
    ecr_scan_on_push    = optional(bool, true)
    ecr_encryption_type = optional(string, "KMS")

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
    svc_monitor_path        = optional(string, "/metrics")
  })
}

variable "image_repository" {
  type        = string
  description = "General repository from where to pull container images from. Specific repositories may still be defined on the respective containers."
  default     = ""
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

variable "ecr_allowed_aws_accounts" {
  type        = list(string)
  description = "AWS accounts allowed to pull from the created ECR."
  default     = []
}

variable "ecr_lifecycle_policy" {
  type        = string
  description = "Sets the lifecycle policy of the ECR. If set `ecr_number_of_images_to_keep` won't work."
  default     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep untagged images for 1 week",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 7
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Keep last 30 images (Main)",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["main"],
                "countType": "imageCountMoreThan",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 3,
            "description": "Keep last 10 images (All except Main)",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 10
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
