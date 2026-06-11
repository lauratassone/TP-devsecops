#!/usr/bin/env sh
set -eu

terraform -chdir=terraform fmt -check -recursive
terraform -chdir=terraform init -backend=false
terraform -chdir=terraform validate

if command -v tflint >/dev/null 2>&1; then
  tflint --init --config "$PWD/.tflint.hcl"
  tflint --chdir=terraform --recursive --config "$PWD/.tflint.hcl"
else
  printf '%s\n' "tflint not found, skipping."
fi

if command -v checkov >/dev/null 2>&1; then
  checkov --config-file .checkov.yml
else
  printf '%s\n' "checkov not found, skipping."
fi

if command -v hadolint >/dev/null 2>&1; then
  hadolint app/Dockerfile
else
  printf '%s\n' "hadolint not found, skipping."
fi

if command -v semgrep >/dev/null 2>&1; then
  semgrep scan --config p/default --config p/golang --config p/dockerfile --config p/terraform --error
else
  printf '%s\n' "semgrep not found, skipping."
fi

if command -v trivy >/dev/null 2>&1 && command -v docker >/dev/null 2>&1; then
  docker build -t tp-devsecops-demo:local app
  trivy image --severity HIGH,CRITICAL --exit-code 1 tp-devsecops-demo:local
else
  printf '%s\n' "trivy or docker not found, skipping image scan."
fi
