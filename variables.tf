variable "name" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "ecr_create" {
  type    = bool
  default = true
}

variable "ecr_scan_on_push" {
  type    = bool
  default = true
}

variable "ecr_number_of_images_to_keep" {
  type    = number
  default = 30
}

variable "svc_create" {
  type    = bool
  default = true
}
