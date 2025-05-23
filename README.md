<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.41.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.23.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.41.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.23.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecr_lifecycle_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |
| [kubernetes_deployment.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_manifest.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_pod_disruption_budget_v1.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/pod_disruption_budget_v1) | resource |
| [kubernetes_service.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [aws_iam_policy_document.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deployment"></a> [deployment](#input\_deployment) | Kubernetes deployment configuration | <pre>object({<br>    name                      = string<br>    prefix                    = string<br>    namespace                 = string<br>    deployment_annotations    = optional(map(string), {})<br>    template_annotations      = optional(map(string), {})<br>    labels                    = optional(map(string), {})<br>    replicas                  = optional(number, 1)<br>    progress_deadline_seconds = optional(number, 600)<br>    affinity = optional(list(<br>      object({<br>        node_affinity     = optional(list(map(any)), [])<br>        pod_affinity      = optional(list(map(any)), [])<br>        pod_anti_affinity = optional(list(map(any)), [])<br>      })<br>    ), [])<br>    volumes          = optional(any, [])<br>    wait_for_rollout = optional(bool, false)<br>    host_aliases = optional(list(object({<br>      ip        = optional(string, "")<br>      hostnames = optional(list(string), [])<br>    })), [])<br><br>    init_container = optional(list(object({<br>      name              = string<br>      image_repository  = optional(string, "")<br>      image_tag         = optional(string, "")<br>      image_pull_policy = optional(string, "IfNotPresent")<br>      env_from          = optional(any, [])<br>      volume_mount      = optional(list(map(any)), [])<br>      command           = optional(list(string), [])<br>      args              = optional(list(string), [])<br>      working_dir       = optional(string)<br>      env               = optional(list(map(any)), [])<br>      resource_limits   = optional(object({ cpu = optional(string), memory = optional(string) }), null)<br>      resource_requests = optional(object({ cpu = optional(string), memory = optional(string) }), null)<br>      lifecycle         = optional(any, [])<br>      security_context  = optional(any, [])<br>    })), [])<br><br>    containers = list(object({<br>      name              = string<br>      image_tag         = optional(string, "")<br>      image_repository  = optional(string, "")<br>      image_pull_policy = optional(string, "IfNotPresent")<br>      env_from          = optional(any, [])<br>      volume_mount      = optional(list(map(any)), [])<br>      command           = optional(list(string), [])<br>      args              = optional(list(string), [])<br>      working_dir       = optional(string)<br>      env               = optional(list(map(any)), [])<br>      resource_limits   = optional(object({ cpu = optional(string), memory = optional(string) }), null)<br>      resource_requests = optional(object({ cpu = optional(string), memory = optional(string) }), null)<br>      lifecycle         = optional(any, [])<br>      liveness_probe = optional(list(object({<br>        failure_threshold     = optional(number)<br>        initial_delay_seconds = optional(number)<br>        period_seconds        = optional(number)<br>        success_threshold     = optional(number)<br>        timeout_seconds       = optional(number)<br>        exec = optional(list(object({<br>          command = optional(list(string))<br>        })), [])<br>        http_get = optional(list(object({<br>          host   = optional(string)<br>          path   = optional(string)<br>          port   = optional(number)<br>          scheme = optional(string)<br>          http_header = optional(list(object({<br>            name  = optional(string)<br>            value = optional(string)<br>          })), [])<br>        })), [])<br>        tcp_socket = optional(list(object({<br>          port = optional(number)<br>        })), [])<br>      })), [])<br>      readiness_probe = optional(list(object({<br>        failure_threshold     = optional(number)<br>        initial_delay_seconds = optional(number)<br>        period_seconds        = optional(number)<br>        success_threshold     = optional(number)<br>        timeout_seconds       = optional(number)<br>        exec = optional(list(object({<br>          command = optional(list(string))<br>        })), [])<br>        http_get = optional(list(object({<br>          host   = optional(string)<br>          path   = optional(string)<br>          port   = optional(number)<br>          scheme = optional(string)<br>          http_header = optional(list(object({<br>            name  = optional(string)<br>            value = optional(string)<br>          })), [])<br>        })), [])<br>        tcp_socket = optional(list(object({<br>          port = optional(number)<br>        })), [])<br>      })), [])<br>      security_context = optional(any, [])<br>    }))<br><br>    termination_grace_period_seconds = optional(number)<br><br>    create              = optional(bool, true)<br>    create_ecr          = optional(bool, false)<br>    ecr_scan_on_push    = optional(bool, true)<br>    ecr_encryption_type = optional(string, "KMS")<br><br>    pdb_create          = optional(bool, true)<br>    pdb_max_unavailable = optional(number, 1)<br>    pdb_min_available   = optional(number)<br><br>    create_svc         = optional(bool, true)<br>    create_svc_monitor = optional(bool, false)<br>    svc_annotations    = optional(map(any), {})<br>    svc_labels         = optional(map(string), {})<br>    svc_ports = optional(list(object({<br>      name        = optional(string)<br>      protocol    = optional(string, "TCP")<br>      port        = optional(number, 80)<br>      target_port = optional(number)<br>    })), [{ name = "http" }])<br>    svc_type                = optional(string, "ClusterIP")<br>    svc_load_balancer_class = optional(string)<br>    svc_monitor_port        = optional(string)<br>    svc_monitor_path        = optional(string, "/metrics")<br>  })</pre> | n/a | yes |
| <a name="input_ecr_allowed_aws_accounts"></a> [ecr\_allowed\_aws\_accounts](#input\_ecr\_allowed\_aws\_accounts) | AWS accounts allowed to pull from the created ECR. | `list(string)` | `[]` | no |
| <a name="input_ecr_lifecycle_policy"></a> [ecr\_lifecycle\_policy](#input\_ecr\_lifecycle\_policy) | Sets the lifecycle policy of the ECR. If set `ecr_number_of_images_to_keep` won't work. | `string` | `"{\n  \"rules\": [\n    {\n      \"rulePriority\": 10,\n      \"description\": \"Keep last 50 images (master)\",\n      \"selection\": {\n        \"tagStatus\": \"tagged\",\n        \"tagPatternList\": [\n          \"master-*\"\n        ],\n        \"countType\": \"imageCountMoreThan\",\n        \"countNumber\": 50\n      },\n      \"action\": {\n        \"type\": \"expire\"\n      }\n    },\n    {\n      \"rulePriority\": 11,\n      \"description\": \"Keep last 50 images (main)\",\n      \"selection\": {\n        \"tagStatus\": \"tagged\",\n        \"tagPatternList\": [\n          \"main-*\"\n        ],\n        \"countType\": \"imageCountMoreThan\",\n        \"countNumber\": 50\n      },\n      \"action\": {\n        \"type\": \"expire\"\n      }\n    },\n    {\n      \"rulePriority\": 20,\n      \"description\": \"Keep last 30 images (develop)\",\n      \"selection\": {\n        \"tagStatus\": \"tagged\",\n        \"tagPatternList\": [\n          \"develop-*\"\n        ],\n        \"countType\": \"imageCountMoreThan\",\n        \"countNumber\": 30\n      },\n      \"action\": {\n        \"type\": \"expire\"\n      }\n    },\n    {\n      \"rulePriority\": 30,\n      \"description\": \"Keep last 50 images of the branches images\",\n      \"selection\": {\n        \"tagStatus\": \"any\",\n        \"countType\": \"imageCountMoreThan\",\n        \"countNumber\": 50\n      },\n      \"action\": {\n        \"type\": \"expire\"\n      }\n    }\n  ]\n}\n\n"` | no |
| <a name="input_image_repository"></a> [image\_repository](#input\_image\_repository) | General repository from where to pull container images from. Specific repositories may still be defined on the respective containers. | `string` | `""` | no |
| <a name="input_strategy_rolling_update"></a> [strategy\_rolling\_update](#input\_strategy\_rolling\_update) | Rolling update config params. Present only if type = RollingUpdate. | `list(any)` | `[]` | no |
| <a name="input_strategy_type"></a> [strategy\_type](#input\_strategy\_type) | Type of deployment. Can be 'Recreate' or 'RollingUpdate'. | `string` | `"RollingUpdate"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_deployment_annotations"></a> [deployment\_annotations](#output\_deployment\_annotations) | The annotations of the deployment |
| <a name="output_deployment_labels"></a> [deployment\_labels](#output\_deployment\_labels) | The labels of the deployment |
| <a name="output_deployment_name"></a> [deployment\_name](#output\_deployment\_name) | The name of the deployment |
| <a name="output_ecr_repository_url"></a> [ecr\_repository\_url](#output\_ecr\_repository\_url) | The URL of the ECR repository |
| <a name="output_svc_address"></a> [svc\_address](#output\_svc\_address) | The address of the service within the cluster |
| <a name="output_svc_name"></a> [svc\_name](#output\_svc\_name) | The name of the service |
| <a name="output_svc_ports"></a> [svc\_ports](#output\_svc\_ports) | The port(s) of the service |
<!-- END_TF_DOCS -->
