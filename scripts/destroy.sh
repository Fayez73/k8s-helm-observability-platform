#!/bin/bash
set -e

echo "Deleting Grafana dashboards..."
kubectl delete -f ../manifests/dashboards/ --ignore-not-found

echo "Deleting RBAC..."
kubectl delete -f ../manifests/rbac.yaml --ignore-not-found

echo "Uninstalling Helm releases..."
helm uninstall prometheus -n monitoring || true
helm uninstall loki -n logging || true
helm uninstall tempo -n monitoring || true

echo "Deleting namespaces..."
kubectl delete -f ../manifests/namespace.yaml --ignore-not-found

echo "Stack destroyed successfully!"
