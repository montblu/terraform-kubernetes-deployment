## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.41.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.14.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.16.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.41.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | >= 1.14.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.16.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecr_lifecycle_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |
| [kubectl_manifest.main](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubernetes_deployment.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_service.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [aws_iam_policy_document.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deployment"></a> [deployment](#input\_deployment) | Kubernetes deployment configuration | <pre>object({<br>    name              = string<br>    prefix            = optional(string)<br>    namespace         = string<br>    annotations       = optional(map(string), {})<br>    labels            = optional(map(string), {})<br>    replicas          = optional(number, 1)<br>    affinity          = optional(list(map(any)), [])<br>    volumes           = optional(any, [])<br>    resource_limits   = optional(object({ cpu = string, memory = string }))<br>    resource_requests = optional(object({ cpu = string, memory = string }))<br>    wait_for_rollout  = optional(bool, false)<br><br>    init_container = optional(list(object({<br>      name              = string<br>      image_repository  = optional(string, "")<br>      image             = optional(string, "")<br>      image_pull_policy = optional(string, "IfNotPresent")<br>      env_from          = optional(list(map(any)), [])<br>      volume_mount      = optional(list(map(any)), [])<br>      command           = optional(list(string), [])<br>      args              = optional(list(string), [])<br>      working_dir       = optional(string)<br>      env_variables     = optional(list(map(any)), [])<br>    })), [])<br>    containers = list(object({<br>      name              = string<br>      image             = optional(string, "")<br>      image_repository  = optional(string, "")<br>      image_pull_policy = optional(string, "IfNotPresent")<br>      liveness_probe    = optional(any, [])<br>      readiness_probe   = optional(any, [])<br>      env_from          = optional(list(map(any)), [])<br>      volume_mount      = optional(list(map(any)), [])<br>      command           = optional(list(string), [])<br>      args              = optional(list(string), [])<br>      working_dir       = optional(string)<br>      env_variables     = optional(list(map(any)), [])<br>    }))<br><br>    create_ecr               = optional(bool, false)<br>    ecr_scan_on_push         = optional(bool, true)<br>    ecr_encryption_type      = optional(string, "KMS")<br><br>    create_svc              = optional(bool, true)<br>    create_svc_monitor      = optional(bool, false)<br>    svc_annotations         = optional(map(any), {})<br>    svc_labels              = optional(map(string), {})<br>    svc_port                = optional(number, 80)<br>    svc_protocol            = optional(string, "TCP")<br>    svc_type                = optional(string, "ClusterIP")<br>    svc_load_balancer_class = optional(string)<br>    svc_monitor_path        = optional(string, "/metrics")<br>  })</pre> | n/a | yes |
| <a name="input_ecr_allowed_aws_accounts"></a> [ecr\_allowed\_aws\_accounts](#input\_ecr\_allowed\_aws\_accounts) | AWS accounts allowed to pull from the created ECR. | `list(string)` | `[]` | no |
| <a name="input_ecr_lifecycle_policy"></a> [ecr\_lifecycle\_policy](#input\_ecr\_lifecycle\_policy) | Sets the lifecycle policy of the ECR. If set `ecr_number_of_images_to_keep` won't work. | `string` | `"{\n    \"rules\": [\n        {\n            \"rulePriority\": 1,\n            \"description\": \"Keep untagged images for 1 week\",\n            \"selection\": {\n                \"tagStatus\": \"untagged\",\n                \"countType\": \"sinceImagePushed\",\n                \"countUnit\": \"days\",\n                \"countNumber\": 7\n            },\n            \"action\": {\n                \"type\": \"expire\"\n            }\n        },\n        {\n            \"rulePriority\": 2,\n            \"description\": \"Keep last 30 images (Main)\",\n            \"selection\": {\n                \"tagStatus\": \"tagged\",\n                \"tagPrefixList\": [\"main\"],\n                \"countType\": \"imageCountMoreThan\",\n                \"countNumber\": 30\n            },\n            \"action\": {\n                \"type\": \"expire\"\n            }\n        },\n        {\n            \"rulePriority\": 3,\n            \"description\": \"Keep last 10 images (All except Main)\",\n            \"selection\": {\n                \"tagStatus\": \"any\",\n                \"countType\": \"imageCountMoreThan\",\n                \"countNumber\": 10\n            },\n            \"action\": {\n                \"type\": \"expire\"\n            }\n        }\n    ]\n}\n"` | no |
| <a name="input_image_repository"></a> [image\_repository](#input\_image\_repository) | General repository from where to pull container images from. Specific repositories may still be defined on the respective containers. | `string` | `""` | no |
| <a name="input_strategy_rolling_update"></a> [strategy\_rolling\_update](#input\_strategy\_rolling\_update) | Rolling update config params. Present only if type = RollingUpdate. | `list(any)` | `[]` | no |
| <a name="input_strategy_type"></a> [strategy\_type](#input\_strategy\_type) | Type of deployment. Can be 'Recreate' or 'RollingUpdate'. | `string` | `"RollingUpdate"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecr_repository_url"></a> [ecr\_repository\_url](#output\_ecr\_repository\_url) | The URL of the ECR repository |