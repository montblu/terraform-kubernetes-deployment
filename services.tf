resource "kubernetes_service" "main" {
  count = var.deployment.create_svc ? 1 : 0

  metadata {
    annotations = var.deployment.svc_annotations
    name        = local.resource_name
    namespace   = var.deployment.namespace

    labels = local.svc_labels
  }

  spec {
    port {
      port        = var.deployment.svc_port
      target_port = var.deployment.svc_port
      protocol    = var.deployment.svc_protocol
    }

    selector = {
      app = local.resource_name
    }

    type                = var.deployment.svc_type
    load_balancer_class = var.deployment.svc_load_balancer_class
  }

  depends_on = [
    kubernetes_deployment.main
  ]
}

resource "kubectl_manifest" "main" {
  count = var.deployment.create_svc && var.deployment.create_svc_monitor ? 1 : 0

  yaml_body = <<YAML
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: ${local.resource_name}
  namespace: ${var.deployment.namespace}
spec:
  selector:
    matchLabels:
      app: ${local.resource_name}
  endpoints:
    - path: "${var.deployment.svc_monitor_path}"
YAML

  depends_on = [
    kubernetes_service.main
  ]
}
