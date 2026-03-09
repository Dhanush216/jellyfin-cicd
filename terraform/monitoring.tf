resource "helm_release" "prometheus_stack" {
  name = "kube-prometheus-stack"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  namespace = "monitoring"

  create_namespace = true

  values = [
    file("${path.module}/prometheus-values.yaml")
  ]
}