resource "kubernetes_namespace" "harbor" {
  metadata {
    name = var.namespace

    labels = {
      "app.kubernetes.io/name"       = "harbor"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "helm_release" "harbor" {
  name       = "harbor"
  namespace  = kubernetes_namespace.harbor.metadata[0].name
  repository = "https://helm.goharbor.io"
  chart      = "harbor"
  version    = var.harbor_chart_version

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 900

  values = [
    templatefile("${path.module}/values.yaml.tftpl", {
      harbor_host        = var.harbor_host
      exposure_type      = var.exposure_type
      tls_enabled        = var.exposure_tls_enabled
      storage_class_name = var.storage_class_name
    })
  ]

  set_sensitive {
    name  = "harborAdminPassword"
    value = var.harbor_admin_password
  }

  depends_on = [kubernetes_namespace.harbor]
}

resource "helm_release" "harbor_monitoring" {
  name      = "harbor-monitoring"
  namespace = kubernetes_namespace.harbor.metadata[0].name
  chart     = "${path.module}/charts/harbor-monitoring"

  set {
    name  = "namespace"
    value = kubernetes_namespace.harbor.metadata[0].name
  }

  depends_on = [
    helm_release.harbor,
    kubernetes_config_map.grafana_dashboard
  ]
}

resource "kubernetes_config_map" "grafana_dashboard" {
  metadata {
    name      = "harbor-grafana-dashboard"
    namespace = kubernetes_namespace.harbor.metadata[0].name

    labels = {
      (var.grafana_dashboard_label) = "1"
    }
  }

  data = {
    "harbor-dashboard.json" = file("${path.root}/../monitoring/grafana/dashboards/harbor-dashboard.json")
  }

  depends_on = [kubernetes_namespace.harbor]
}
