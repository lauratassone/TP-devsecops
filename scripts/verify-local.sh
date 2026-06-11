#!/usr/bin/env sh
set -eu

terraform -chdir=terraform fmt -check -recursive
terraform -chdir=terraform init -backend=false
terraform -chdir=terraform validate

if command -v tflint >/dev/null 2>&1; then
  tflint --init --config .tflint.hcl
  tflint --recursive --config .tflint.hcl
fi

if command -v checkov >/dev/null 2>&1; then
  checkov --config-file .checkov.yml
fi

if command -v hadolint >/dev/null 2>&1; then
  hadolint app/Dockerfile
fi
