variable "name" {
  type        = string
  description = "Name of the deployment."
}

variable "name_prefix" {
  type        = string
  description = "Prefix that is going to be added to deployment name."
}

variable "ecr_create" {
  type        = bool
  default     = true
  description = "Controls if ECR repo should be created."
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

variable "annotations" {
  type        = map(any)
  default     = {}
  description = "Map of annotations to add to the Deployment."
}
variable "command" {
  type        = list(string)
  default     = []
  description = "Entrypoint list of the image."
}

variable "image" {
  type        = string
  default     = ""
  description = "Docker image name."
}

variable "labels" {
  type        = map(any)
  default     = {}
  description = "Map of string keys and values that can be used to organize and categorize (scope and select) the deployment."
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

variable "svc_create" {
  type        = bool
  default     = true
  description = "Controls if a service should be created for the deployment."
}

variable "svc_port" {
  type        = number
  description = "The port on the service that is hosting the service."
}

variable "svc_protocol" {
  type        = string
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
  description = "Controls whether a ServiceMonitor should be created."
}

variable "wait_for_rollout" {
  type        = bool
  default     = false
  description = "Controls wheter Terraform should wait for deployment to be healthy."
}
