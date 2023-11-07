<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
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
| <a name="input_additional_containers"></a> [additional\_containers](#input\_additional\_containers) | List of containers belonging to the pod. | `list(any)` | `[]` | no |
| <a name="input_affinity"></a> [affinity](#input\_affinity) | A group of affinity scheduling rules. If specified, the pod will be dispatched by specified scheduler. If not specified, the pod will be dispatched by default scheduler. | `list(any)` | `[]` | no |
| <a name="input_annotations"></a> [annotations](#input\_annotations) | Map of annotations to add to the Deployment. | `map(string)` | `{}` | no |
| <a name="input_args"></a> [args](#input\_args) | Arguments to the entrypoint. | `list(string)` | `[]` | no |
| <a name="input_command"></a> [command](#input\_command) | Entrypoint list of the image. | `list(string)` | `[]` | no |
| <a name="input_ecr_allowed_aws_accounts"></a> [ecr\_allowed\_aws\_accounts](#input\_ecr\_allowed\_aws\_accounts) | AWS accounts allowed to pull from the created ECR | `list(string)` | `[]` | no |
| <a name="input_ecr_create"></a> [ecr\_create](#input\_ecr\_create) | Controls if ECR repo should be created. | `bool` | `true` | no |
| <a name="input_ecr_encryption_type"></a> [ecr\_encryption\_type](#input\_ecr\_encryption\_type) | The encryption type for the repository. Must be one of: `KMS` or `AES256`. | `string` | `"KMS"` | no |
| <a name="input_ecr_lifecycle_policy"></a> [ecr\_lifecycle\_policy](#input\_ecr\_lifecycle\_policy) | Sets the lifecycle policy of the ECR. If set `ecr_number_of_images_to_keep` won't work. | `string` | `""` | no |
| <a name="input_ecr_scan_on_push"></a> [ecr\_scan\_on\_push](#input\_ecr\_scan\_on\_push) | Controls if ECR should scan images after pushed. | `bool` | `true` | no |
| <a name="input_env"></a> [env](#input\_env) | Block of string name and value pairs to set in the container's environment. | `list(any)` | `[]` | no |
| <a name="input_env_from"></a> [env\_from](#input\_env\_from) | List of sources to populate environment variables in the container. | `any` | `[]` | no |
| <a name="input_image_pull_policy"></a> [image\_pull\_policy](#input\_image\_pull\_policy) | Image pull policy. One of Always, Never, IfNotPresent. | `string` | `"IfNotPresent"` | no |
| <a name="input_image_repository"></a> [image\_repository](#input\_image\_repository) | The repository where the image is pulled from. If unspecified and var.ecr\_create is true, it will use the created ECR repository url. Howevever, if unspecified and var.ecr\_create is false, it will use 'dummy' as placeholder - may be used when the image is set by some external process to this module. | `string` | `""` | no |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | Tag of the image used. If not specified will use empty tag. | `string` | `""` | no |
| <a name="input_init_container"></a> [init\_container](#input\_init\_container) | List of init containers belonging to the pod. Init containers always run to completion and each must complete successfully before the next is started. | `list(any)` | `[]` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Map of string keys and values that can be used to organize and categorize (scope and select) the deployment. | `map(any)` | `{}` | no |
| <a name="input_liveness_probe"></a> [liveness\_probe](#input\_liveness\_probe) | Periodic probe of container liveness. Container will be restarted if the probe fails. | `list(any)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the deployment. | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix that is going to be added to deployment name. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace of where the deployment will be deployed. | `string` | n/a | yes |
| <a name="input_readiness_probe"></a> [readiness\_probe](#input\_readiness\_probe) | Periodic probe of container service readiness. Container will be removed from service endpoints if the probe fails. | `list(any)` | `[]` | no |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | The number of desired replicas. | `number` | `1` | no |
| <a name="input_resource_limits"></a> [resource\_limits](#input\_resource\_limits) | Describes the maximum amount of compute resources allowed. | `map(string)` | `{}` | no |
| <a name="input_resource_requests"></a> [resource\_requests](#input\_resource\_requests) | Describes the minimum amount of compute resources required. | `map(string)` | `{}` | no |
| <a name="input_strategy_rolling_update"></a> [strategy\_rolling\_update](#input\_strategy\_rolling\_update) | Rolling update config params. Present only if type = RollingUpdate. | `list(any)` | `[]` | no |
| <a name="input_strategy_type"></a> [strategy\_type](#input\_strategy\_type) | Type of deployment. Can be 'Recreate' or 'RollingUpdate'. Default is RollingUpdate. | `string` | `"RollingUpdate"` | no |
| <a name="input_svc_annotations"></a> [svc\_annotations](#input\_svc\_annotations) | Map of annotations to add to the Service. | `map(any)` | `{}` | no |
| <a name="input_svc_create"></a> [svc\_create](#input\_svc\_create) | Controls if a service should be created for the deployment. | `bool` | `true` | no |
| <a name="input_svc_labels"></a> [svc\_labels](#input\_svc\_labels) | Map of string keys and values that can be used to organize and categorize (scope and select) the service. | `map(any)` | `{}` | no |
| <a name="input_svc_load_balancer_class"></a> [svc\_load\_balancer\_class](#input\_svc\_load\_balancer\_class) | The class of the load balancer implementation this Service belongs to. If specified, the value of this field must be a label-style identifier, with an optional prefix. This field can only be set when the Service type is LoadBalancer. If not set, the default load balancer implementation is used. | `string` | `""` | no |
| <a name="input_svc_monitor_create"></a> [svc\_monitor\_create](#input\_svc\_monitor\_create) | Controls whether a ServiceMonitor should be created. The `svc_create` is required to be enabled. | `bool` | `false` | no |
| <a name="input_svc_monitor_path"></a> [svc\_monitor\_path](#input\_svc\_monitor\_path) | Controls where the ServiceMonitor should scrape from. | `string` | `"/metrics"` | no |
| <a name="input_svc_port"></a> [svc\_port](#input\_svc\_port) | The port on the service that is hosting the service. | `number` | n/a | yes |
| <a name="input_svc_protocol"></a> [svc\_protocol](#input\_svc\_protocol) | The protocol that the port of the service has. | `string` | `"TCP"` | no |
| <a name="input_svc_type"></a> [svc\_type](#input\_svc\_type) | Controls the type of the service created. | `string` | `"ClusterIP"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_volume"></a> [volume](#input\_volume) | List of volumes that can be mounted by containers belonging to the pod. | `any` | `[]` | no |
| <a name="input_volume_mount"></a> [volume\_mount](#input\_volume\_mount) | Path within the container at which the volume should be mounted. Must not contain ':'. | `list(any)` | `[]` | no |
| <a name="input_wait_for_rollout"></a> [wait\_for\_rollout](#input\_wait\_for\_rollout) | Controls wheter Terraform should wait for deployment to be healthy. | `bool` | `false` | no |
| <a name="input_working_dir"></a> [working\_dir](#input\_working\_dir) | Container's working directory. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecr_repository_url"></a> [ecr\_repository\_url](#output\_ecr\_repository\_url) | The URL of the ECR repository |
<!-- END_TF_DOCS -->