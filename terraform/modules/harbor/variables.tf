variable "namespace" {
  description = "Namespace Kubernetes Harbor."
  type        = string
}

variable "harbor_host" {
  description = "Nom DNS de Harbor."
  type        = string
}

variable "harbor_admin_password" {
  description = "Mot de passe administrateur Harbor."
  type        = string
  sensitive   = true
}

variable "harbor_chart_version" {
  description = "Version du chart Helm Harbor."
  type        = string
}

variable "exposure_type" {
  description = "Type d'exposition Harbor."
  type        = string
}

variable "exposure_tls_enabled" {
  description = "Active TLS Harbor."
  type        = bool
}

variable "storage_class_name" {
  description = "StorageClass pour les PVC."
  type        = string
}

variable "grafana_dashboard_label" {
  description = "Label de decouverte des dashboards Grafana."
  type        = string
}
