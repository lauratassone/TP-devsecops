# TP 03 - Harbor + Terraform + CI/CD securisee

Ce depot livre un TP complet pour deployer Harbor sur k3s avec Terraform et securiser une pipeline GitHub Actions.

## Objectifs couverts

- Harbor deploye sur k3s via Terraform et le provider Helm.
- Controle IaC avec `terraform fmt`, `terraform validate`, `tflint` et `checkov`.
- Pipeline GitHub Actions bloquante : `hadolint`, `Semgrep`, `Trivy`, `ZAP baseline`.
- Build, push Harbor et signature Cosign keyless.
- Observabilite Harbor : metrics exposees, `ServiceMonitor` Prometheus et dashboard Grafana CVE/registry.

## Arborescence

```text
.
├── app/                         # Application de demonstration pour CI/CD
├── terraform/                   # Root Terraform + module Helm Harbor
├── monitoring/                  # Dashboard Grafana Harbor
├── .github/workflows/ci.yml     # Pipeline securisee
├── .checkov.yml                 # Configuration Checkov
├── .semgrepignore               # Exclusions Semgrep
├── .tflint.hcl                  # Configuration TFLint
└── docs/                        # Procedure de rendu
```

## Prerequis locaux

- Un cluster k3s accessible via `kubectl`.
- `terraform >= 1.6`.
- `helm >= 3`.
- `kubectl`.
- Optionnel pour les controles locaux : `tflint`, `checkov`, `hadolint`, `trivy`, `semgrep`, `cosign`.
- Prometheus Operator deja installe si vous voulez que le `ServiceMonitor` soit pris en compte.

## Deploiement Harbor

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Verifiez ensuite les pods :

```bash
kubectl get pods -n harbor
kubectl get svc -n harbor
kubectl get servicemonitor -n harbor
```

## Acces Harbor

Par defaut, le TP utilise `harbor.local` et une exposition `clusterIP`. Pour un poste local :

```bash
kubectl -n harbor port-forward svc/harbor-portal 8080:80
```

Puis ouvrez `http://localhost:8080`.

Pour un vrai nom DNS, adaptez `harbor_host`, `exposure_type`, `exposure_tls_enabled` et les annotations Ingress dans `terraform/terraform.tfvars`.

## Secrets GitHub Actions

Configurez ces variables/secrets dans le depot GitHub :

| Nom | Type | Exemple |
| --- | --- | --- |
| `HARBOR_REGISTRY` | variable | `harbor.example.com` |
| `HARBOR_PROJECT` | variable | `library` |
| `HARBOR_USERNAME` | secret | `robot$ci` |
| `HARBOR_PASSWORD` | secret | `***` |
| `DAST_TARGET_URL` | variable | `https://staging.example.com` |

La signature Cosign est keyless et utilise l'OIDC GitHub Actions. Il faut donc garder la permission `id-token: write`.

## Pipeline

La pipeline `.github/workflows/ci.yml` execute :

1. Qualite Dockerfile avec Hadolint.
2. IaC Terraform avec `terraform validate`, TFLint et Checkov.
3. SAST Semgrep.
4. Scan CVE Trivy bloquant avec `exit-code: 1`.
5. Build et push Docker vers Harbor.
6. Signature Cosign keyless de l'image poussee.
7. DAST OWASP ZAP baseline sur l'URL cible.

## Observabilite

Le chart Harbor expose les metriques via `metrics.enabled=true`.

Le module Terraform cree :

- un `ServiceMonitor` Prometheus Operator ;
- une `ConfigMap` de dashboard Grafana avec le label `grafana_dashboard=1`.

Le dashboard suit notamment :

- etat des jobs Harbor ;
- activite registry HTTP ;
- indicateurs lies aux scans d'artefacts et CVE quand les metriques Harbor/Trivy Adapter sont disponibles.

## Rendu

Voir [docs/livrable.md](docs/livrable.md) pour la procedure detaillee et la checklist de soutenance.
