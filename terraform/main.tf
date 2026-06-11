module "harbor" {
  source = "./modules/harbor"

  namespace               = var.harbor_namespace
  harbor_host             = var.harbor_host
  harbor_admin_password   = var.harbor_admin_password
  harbor_chart_version    = var.harbor_chart_version
  exposure_type           = var.exposure_type
  exposure_tls_enabled    = var.exposure_tls_enabled
  storage_class_name      = var.storage_class_name
  grafana_dashboard_label = var.grafana_dashboard_label
}
