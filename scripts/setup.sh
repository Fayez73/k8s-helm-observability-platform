#!/bin/bash
set -euo pipefail

# Observability Stack Setup Script
# Deploys Prometheus, Grafana, Loki, Tempo, RBAC, dashboards, and TLS ingress

# Environment variable: EXPOSE_PROMETHEUS (true/false)
EXPOSE_PROMETHEUS=${EXPOSE_PROMETHEUS:-false}

# -------------------------------
# 1. Create namespaces
# -------------------------------
kubectl apply -f ../manifests/namespace.yaml

# -------------------------------
# 2. Install cert-manager
# -------------------------------
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
kubectl apply -f ../manifests/cert-manager/clusterissuer.yaml

# Wait for cert-manager pods to be ready
kubectl wait --for=condition=Ready pods --all -n cert-manager --timeout=180s

# -------------------------------
# 3. Add Helm repos
# -------------------------------
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# -------------------------------
# 4. Deploy Prometheus + Grafana + Loki + Tempo
# -------------------------------
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f ../charts/kube-prometheus-stack-values.yaml

helm upgrade --install loki grafana/loki-stack \
  -n logging \
  -f ../charts/loki-values.yaml

helm upgrade --install tempo grafana/tempo \
  -n monitoring \
  -f ../charts/tempo-values.yaml

# -------------------------------
# 5. Apply RBAC
# -------------------------------
kubectl apply -f ../manifests/rbac.yaml

# -------------------------------
# 6. Apply Grafana dashboards
# -------------------------------
kubectl apply -f ../manifests/dashboards/

# -------------------------------
# 7. Apply TLS-enabled Ingress
# -------------------------------
kubectl apply -f ../manifests/ingress-grafana.yaml

if [ "$EXPOSE_PROMETHEUS" = "true" ]; then
  kubectl apply -f ../manifests/ingress-prometheus.yaml
fi

# -------------------------------
# 8. Reminder for Alertmanager integration
# -------------------------------
echo "Observability stack deployed successfully."
echo "Reminder: Configure Alertmanager Slack/MS Teams integration separately using scripts/setup-alerts.sh"
