#!/bin/bash
set -euo pipefail

# Observability Stack Teardown Script
# Uninstalls Helm releases, removes dashboards, RBAC, ingress, and namespaces

# Environment variable: EXPOSE_PROMETHEUS (true/false)
EXPOSE_PROMETHEUS=${EXPOSE_PROMETHEUS:-false}

# -------------------------------
# 1. Delete TLS-enabled Ingress
# -------------------------------
kubectl delete -f ../manifests/ingress-grafana.yaml --ignore-not-found

if [ "$EXPOSE_PROMETHEUS" = "true" ]; then
  kubectl delete -f ../manifests/ingress-prometheus.yaml --ignore-not-found
fi

# -------------------------------
# 2. Delete Grafana dashboards
# -------------------------------
kubectl delete -f ../manifests/dashboards/ --ignore-not-found

# -------------------------------
# 3. Delete RBAC
# -------------------------------
kubectl delete -f ../manifests/rbac.yaml --ignore-not-found

# -------------------------------
# 4. Uninstall Helm releases
# -------------------------------
helm uninstall prometheus -n monitoring || true
helm uninstall loki -n logging || true
helm uninstall tempo -n monitoring || true

# -------------------------------
# 5. Delete namespaces
# -------------------------------
kubectl delete namespace monitoring --ignore-not-found
kubectl delete namespace logging --ignore-not-found

echo "Observability stack teardown complete."
