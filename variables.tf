variable "name" {
  type        = string
  description = "Name of the deployment."
}

variable "name_prefix" {
  type        = string
  description = "Prefix that is going to be added to deployment name."
}

variable "additional_containers" {
  type        = list(any)
  default     = []
  description = "List of containers belonging to the pod."
}

variable "affinity" {
  type        = list(any)
  default     = []
  description = "A group of affinity scheduling rules. If specified, the pod will be dispatched by specified scheduler. If not specified, the pod will be dispatched by default scheduler."
}

variable "args" {
  type        = list(string)
  default     = []
  description = "Arguments to the entrypoint."
}

variable "ecr_allowed_aws_accounts" {
  type        = list(string)
  default     = []
  description = "AWS accounts allowed to pull from the created ECR"
}

variable "ecr_create" {
  type        = bool
  default     = true
  description = "Controls if ECR repo should be created."
}

variable "ecr_encryption_type" {
  type        = string
  default     = "KMS"
  description = "The encryption type for the repository. Must be one of: `KMS` or `AES256`."
}

variable "ecr_lifecycle_policy" {
  type        = string
  default     = ""
  description = "Sets the lifecycle policy of the ECR. If set `ecr_number_of_images_to_keep` won't work."
}

variable "ecr_scan_on_push" {
  type        = bool
  default     = true
  description = "Controls if ECR should scan images after pushed."
}

variable "ecr_number_of_images_to_keep" {
  type        = number
  default     = 30
  description = "Controls how many images should be kept in the ECR repo."
}

variable "init_container" {
  type        = list(any)
  default     = []
  description = "List of init containers belonging to the pod. Init containers always run to completion and each must complete successfully before the next is started."
}

variable "annotations" {
  type        = map(string)
  default     = {}
  description = "Map of annotations to add to the Deployment."
}
variable "command" {
  type        = list(string)
  default     = []
  description = "Entrypoint list of the image."
}

variable "env" {
  type        = list(any)
  default     = []
  description = "Block of string name and value pairs to set in the container's environment."
}

variable "env_from" {
  type        = any
  default     = []
  description = "List of sources to populate environment variables in the container."
}

variable "image" {
  type        = string
  default     = ""
  description = "Docker image name."
}

variable "image_pull_policy" {
  type        = string
  default     = "IfNotPresent"
  description = "Image pull policy. One of Always, Never, IfNotPresent."
}

variable "labels" {
  type        = map(any)
  default     = {}
  description = "Map of string keys and values that can be used to organize and categorize (scope and select) the deployment."
}

variable "liveness_probe" {
  type        = list(any)
  default     = []
  description = "Periodic probe of container liveness. Container will be restarted if the probe fails."
}

variable "readiness_probe" {
  type        = list(any)
  default     = []
  description = "Periodic probe of container service readiness. Container will be removed from service endpoints if the probe fails."
}

variable "namespace" {
  type        = string
  description = "Namespace of where the deployment will be deployed."
}

variable "replicas" {
  type        = number
  default     = 1
  description = "The number of desired replicas."
}

variable "resource_limits" {
  type        = map(string)
  default     = {}
  description = "Describes the maximum amount of compute resources allowed."
}

variable "resource_requests" {
  type        = map(string)
  default     = {}
  description = "Describes the minimum amount of compute resources required."
}

variable "strategy_type" {
  type        = string
  default     = "RollingUpdate"
  description = "Type of deployment. Can be 'Recreate' or 'RollingUpdate'. Default is RollingUpdate."
}

variable "strategy_rolling_update" {
  type = list(any)
  default = []
  description = "Rolling update config params. Present only if type = RollingUpdate."
}

variable "svc_annotations" {
  type        = map(any)
  default     = {}
  description = "Map of annotations to add to the Service."
}

variable "svc_create" {
  type        = bool
  default     = true
  description = "Controls if a service should be created for the deployment."
}

variable "svc_labels" {
  type        = map(any)
  default     = {}
  description = "Map of string keys and values that can be used to organize and categorize (scope and select) the service."
}

variable "svc_load_balancer_class" {
  type        = string
  default     = ""
  description = "The class of the load balancer implementation this Service belongs to. If specified, the value of this field must be a label-style identifier, with an optional prefix. This field can only be set when the Service type is LoadBalancer. If not set, the default load balancer implementation is used."
}

variable "svc_port" {
  type        = number
  description = "The port on the service that is hosting the service."
}

variable "svc_protocol" {
  type        = string
  default     = "TCP"
  description = "The protocol that the port of the service has."
}

variable "svc_type" {
  type        = string
  default     = "ClusterIP"
  description = "Controls the type of the service created."
}

variable "svc_monitor_create" {
  type        = bool
  default     = false
  description = "Controls whether a ServiceMonitor should be created. The `svc_create` is required to be enabled."
}

variable "svc_monitor_path" {
  type        = string
  default     = "/metrics"
  description = "Controls where the ServiceMonitor should scrape from."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to add to all resources"
}

variable "volume" {
  type        = any
  default     = []
  description = "List of volumes that can be mounted by containers belonging to the pod."
}

variable "volume_mount" {
  type        = list(any)
  default     = []
  description = "Path within the container at which the volume should be mounted. Must not contain ':'."
}

variable "wait_for_rollout" {
  type        = bool
  default     = false
  description = "Controls wheter Terraform should wait for deployment to be healthy."
}

variable "working_dir" {
  type        = string
  default     = ""
  description = "Container's working directory."
}
