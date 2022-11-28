resource "kubernetes_service" "main" {
  count = var.svc_create ? 1 : 0

  metadata {
    name      = local.resource_name
    namespace = var.namespace

    labels = {
      app = local.resource_name
    }
  }

  spec {
    port {
      port        = var.svc_port
      target_port = var.svc_port
      protocol    = var.svc_protocol
    }

    selector = {
      app = local.resource_name
    }

    type = var.svc_type
  }
}
