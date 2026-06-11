variable "kubeconfig_path" {
  description = "Chemin vers le kubeconfig k3s."
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Contexte kubeconfig a utiliser. Laisser null pour le contexte courant."
  type        = string
  default     = null
}

variable "harbor_namespace" {
  description = "Namespace Kubernetes Harbor."
  type        = string
  default     = "harbor"
}

variable "harbor_host" {
  description = "Nom DNS public ou local de Harbor."
  type        = string
  default     = "harbor.local"
}

variable "harbor_admin_password" {
  description = "Mot de passe administrateur Harbor."
  type        = string
  sensitive   = true
}

variable "harbor_chart_version" {
  description = "Version du chart Helm Harbor."
  type        = string
  default     = "1.15.1"
}

variable "exposure_type" {
  description = "Type d'exposition Harbor: ingress, clusterIP, nodePort ou loadBalancer."
  type        = string
  default     = "clusterIP"

  validation {
    condition     = contains(["ingress", "clusterIP", "nodePort", "loadBalancer"], var.exposure_type)
    error_message = "exposure_type doit valoir ingress, clusterIP, nodePort ou loadBalancer."
  }
}

variable "exposure_tls_enabled" {
  description = "Active TLS sur l'exposition Harbor."
  type        = bool
  default     = false
}

variable "storage_class_name" {
  description = "StorageClass k3s pour les PVC Harbor."
  type        = string
  default     = "local-path"
}

variable "grafana_dashboard_label" {
  description = "Label utilise par le sidecar Grafana pour importer les dashboards."
  type        = string
  default     = "grafana_dashboard"
}
