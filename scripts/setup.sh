#!/bin/bash
set -e

# -------------------------------
# Observability Stack Setup Script
# -------------------------------
echo "✅ Starting Observability Stack setup..."

# -------------------------------
# 1. Create namespaces
# -------------------------------
echo "📂 Creating namespaces..."
kubectl apply -f ../manifests/namespace.yaml

# -------------------------------
# 2. Install cert-manager
# -------------------------------
echo "🔐 Installing cert-manager..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
kubectl apply -f ../manifests/cert-manager/clusterissuer.yaml

echo "⏳ Waiting for cert-manager pods to be ready..."
kubectl wait --for=condition=Ready pods --all -n cert-manager --timeout=180s

# -------------------------------
# 3. Add Helm repos
# -------------------------------
echo "📦 Adding Helm repos..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# -------------------------------
# 4. Deploy Prometheus + Grafana + Loki + Tempo
# -------------------------------
echo "📈 Installing Prometheus stack..."
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f ../charts/kube-prometheus-stack-values.yaml

echo "🗂 Installing Loki stack..."
helm upgrade --install loki grafana/loki-stack \
  -n logging \
  -f ../charts/loki-values.yaml

echo "⏱ Installing Tempo..."
helm upgrade --install tempo grafana/tempo \
  -n monitoring \
  -f ../charts/tempo-values.yaml

# -------------------------------
# 5. Apply RBAC
# -------------------------------
echo "🛡 Applying RBAC..."
kubectl apply -f ../manifests/rbac.yaml

# -------------------------------
# 6. Apply Grafana dashboards
# -------------------------------
echo "📊 Applying Grafana dashboards..."
kubectl apply -f ../manifests/dashboards/

# -------------------------------
# 7. Apply TLS-enabled Ingress
# -------------------------------
echo "🌐 Applying TLS Ingress for Grafana..."
kubectl apply -f ../manifests/ingress-grafana.yaml

# Optional Prometheus ingress
if [ "$EXPOSE_PROMETHEUS" = "true" ]; then
  echo "🌐 Applying TLS Ingress for Prometheus..."
  kubectl apply -f ../manifests/ingress-prometheus.yaml
else
  echo "ℹ️ Skipping Prometheus external ingress (EXPOSE_PROMETHEUS=false)"
fi

echo "🎉 Observability stack deployed successfully!"
