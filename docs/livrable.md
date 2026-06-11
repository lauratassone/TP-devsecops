# Livrable TP 03 - Harbor + Terraform + CI pipeline securisee

## 1. Deploiement Harbor par IaC

Le dossier `terraform/` contient un root module qui appelle `modules/harbor`.

Le module realise :

- creation du namespace `harbor` ;
- installation du chart Helm `harbor` depuis `https://helm.goharbor.io` ;
- activation de Trivy cote Harbor ;
- activation des metriques Harbor ;
- creation d'un `ServiceMonitor` ;
- creation d'une `ConfigMap` Grafana pour le dashboard.

Commandes attendues :

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

## 2. Controles IaC

La pipeline execute :

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
tflint --recursive --config ../.tflint.hcl
checkov --config-file .checkov.yml
```

Ces controles bloquent la CI en cas d'erreur.

## 3. Pipeline securisee GitHub Actions

Fichier : `.github/workflows/ci.yml`.

Etapes :

1. Hadolint controle `app/Dockerfile`.
2. Semgrep lance les rulesets `p/default`, `p/javascript`, `p/dockerfile`, `p/terraform`.
3. Trivy scanne l'image sur les severites `HIGH,CRITICAL` avec `exit-code: 1`.
4. L'image est poussee dans Harbor.
5. Cosign signe l'image en keyless avec l'OIDC GitHub.
6. OWASP ZAP baseline scanne l'URL de staging.

Secrets et variables GitHub :

```text
vars.HARBOR_REGISTRY
vars.HARBOR_PROJECT
secrets.HARBOR_USERNAME
secrets.HARBOR_PASSWORD
vars.DAST_TARGET_URL
```

## 4. Observabilite

Harbor expose `/metrics` sur ses composants. Le `ServiceMonitor` est deploye dans le namespace Harbor et selectionne les services du chart.

Dashboard :

```text
monitoring/grafana/dashboards/harbor-dashboard.json
```

Panels inclus :

- nombre de projets Harbor ;
- pulls/pushes registry ;
- CVE high/critical ;
- taux HTTP registry ;
- CVE par severite.

## 5. Checklist de demonstration

```bash
kubectl get pods -n harbor
kubectl get svc -n harbor
kubectl get servicemonitor -n harbor
kubectl get cm harbor-grafana-dashboard -n harbor
```

Dans GitHub Actions, montrer :

- job Hadolint vert ;
- job Terraform/TFLint/Checkov vert ;
- job Semgrep vert ;
- job Trivy bloquant sur HIGH/CRITICAL ;
- image poussee dans Harbor ;
- signature Cosign presente ;
- rapport ZAP baseline.

Dans Grafana, importer ou ouvrir le dashboard `Harbor registry security`.
