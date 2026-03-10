resource "helm_release" "jellyfin" {
  name             = "jellyfin-new"
  namespace        = "jellyfin-terraform"
  create_namespace = true

  repository = "https://jellyfin.github.io/jellyfin-helm"
  chart      = "jellyfin"

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 600

  values = [
    file("${path.module}/jellyfin-values.yaml"),
    yamlencode({
      service = {
        type     = "NodePort"
        nodePort = 31318
      }
    })
  ]
}