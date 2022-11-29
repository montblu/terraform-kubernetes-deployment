resource "kubectl_manifest" "main" {
  count = var.svc_create ? (var.svc_monitor_create ? 1 : 0) : 0

  yaml_body = <<YAML
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: ${local.resource_name}
  namespace: ${var.namespace}
spec:
  selector:
    matchLabels:
      app: ${local.resource_name}
  endpoints:
    - path: "${var.svc_monitor_path}"
YAML

  depends_on = [
    kubernetes_service.main
  ]
}
