#!/bin/bash
set -e

echo "Creating namespaces..."
kubectl apply -f ../manifests/namespace.yaml

echo "Installing Prometheus stack..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f ../charts/kube-prometheus-stack-values.yaml

echo "Installing Loki..."
helm repo add grafana https://grafana.github.io/helm-charts
helm upgrade --install loki grafana/loki-stack \
  -n logging \
  -f ../charts/loki-values.yaml

echo "Installing Tempo..."
helm upgrade --install tempo grafana/tempo \
  -n monitoring \
  -f ../charts/tempo-values.yaml

echo "Applying RBAC..."
kubectl apply -f ../manifests/rbac.yaml

echo "Applying Grafana dashboards..."
kubectl apply -f ../manifests/dashboards/

echo "Observability stack deployed successfully!"
