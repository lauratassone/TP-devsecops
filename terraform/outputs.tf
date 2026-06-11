output "harbor_namespace" {
  description = "Namespace Harbor."
  value       = module.harbor.namespace
}

output "harbor_url" {
  description = "URL Harbor configuree."
  value       = module.harbor.harbor_url
}

output "service_monitor_name" {
  description = "Nom du ServiceMonitor Harbor."
  value       = module.harbor.service_monitor_name
}
