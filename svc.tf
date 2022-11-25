resource "kubernetes_service" "main" {
  count = var.svc_create ? 1 : 0

  metadata {
    name      = local.resource_name
    namespace = "${var.name_prefix}-app"

    labels = {
      app = local.resource_name
    }
  }

  spec {
    port {
      name        = "gunicorn"
      protocol    = "TCP"
      port        = 80
      target_port = "5000"
    }

    selector = {
      app = local.resource_name
    }

    type = var.svc_type
  }
}
