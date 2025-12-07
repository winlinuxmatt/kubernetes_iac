# Longhorn installation via Helm (minimal)

resource "helm_release" "longhorn" {
  name             = "longhorn"
  repository       = "https://charts.longhorn.io"
  chart            = "longhorn"
  namespace        = "longhorn-system"
  create_namespace = true

  # Use default Longhorn settings, plus a couple of sane defaults
  set {
    name  = "defaultSettings.defaultDataPath"
    value = "/var/lib/longhorn/"
  }

  set {
    name  = "persistence.defaultClass"
    value = "true"
  }

  set {
    name  = "persistence.defaultClassReplicaCount"
    value = "3"
  }

  # Ensure kubeconfig is written before Helm connects to the cluster
  depends_on = [
    null_resource.run_custom_script
  ]
}
