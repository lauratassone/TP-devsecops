output "namespace" {
  description = "Namespace Harbor."
  value       = kubernetes_namespace.harbor.metadata[0].name
}

output "harbor_url" {
  description = "URL Harbor configuree."
  value       = var.exposure_tls_enabled ? "https://${var.harbor_host}" : "http://${var.harbor_host}"
}

output "service_monitor_name" {
  description = "Nom du ServiceMonitor Harbor."
  value       = "harbor"
}
