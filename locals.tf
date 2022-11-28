locals {
  resource_name = "${var.name_prefix}-${var.name}"

  annotations = var.annotations
  default_labels = {
    app = local.resource_name
  }

  labels = var.labels == {} ? local.default_labels : merge(local.default_labels, var.labels)
}
