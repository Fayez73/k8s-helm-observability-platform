# k8s-helm-observability-platform

# 🚀 Observability Stack on Kubernetes (GitOps + Helm + AWS)

## 🔹 Project Overview
This project builds a **production-ready observability stack** on Kubernetes using Helm charts.  
It covers **metrics, logs, and traces** in a GitOps-style deployment with support for Argo CD or Flux.

This stack is deployed on EKS via terraform

---

## ✨ Features
- **Metrics** → Prometheus for collection, Grafana for visualization  
- **Logs** → Loki or Elastic/Opensearch for log aggregation  
- **Traces** → Tempo or Jaeger for distributed tracing  
- **Dashboards as Code** → Grafana dashboards deployed from Helm values  
- **Alerting** → Alertmanager + Slack/MS Teams webhook integration  
- **Security** → RBAC, namespace isolation, TLS/ingress  

---

## 🛠️ Tech Stack
- **Kubernetes** → EKS, GKE, or local Kind/MiniKube  
- **Helm** → Package manager for reproducible deployments  
- **Prometheus** → Metrics & alerting  
- **Grafana** → Dashboards, logs, traces visualization  
- **Loki / Tempo** → Logs + traces  
- **Terraform** → Cluster + Helm releases automation  
- **Argo CD / Flux (optional)** → GitOps workflow  

---

## 📂 Project Structure
```bash
observability-as-code/
├─ README.md                       # Project overview, setup instructions
├── argocd-apps
├── aws
│   ├── envs
│   │   ├── dev
│   │   └── prod
│   └── modules
│       ├── eks
│       ├── iam
│       └── vpc
├── charts
├── manifests
│   ├── alert-manager
│   ├── cert-manager
│   └── dashboards
├── scripts
└── workflows


```
---

## 🚀 Deployment Steps

- Running the setup script will deploy everything
```bash
scripts/setup.sh
```
1. Prerequisites

- A running Kubernetes cluster (EKS/GKE/AKS/Kind/Minikube)

- kubectl and helm installed

- (Optional) argocd CLI for GitOps setup

2. Create Namespaces
```bash
kubectl create namespace monitoring
kubectl create namespace logging
```

3. Install Prometheus
```bash

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f charts/prometheus-values.yaml

```
4. Install Grafana
```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm upgrade --install grafana grafana/grafana \
  -n monitoring \
  -f charts/grafana-values.yaml
```

5. Install Loki (for logs)
```bash
helm upgrade --install loki grafana/loki-stack \
  -n logging \
  -f charts/loki-values.yaml
```
6. Install Tempo (for traces)
```bash
helm upgrade --install tempo grafana/tempo \
  -n monitoring \
  -f charts/tempo-values.yaml
```

7. GitOps with Argo CD (optional)
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
7.1. Create an Argo CD Application for Observability stack:
 - Found in argocd-apps directory

7.2. Apply the app
```bash
kubectl apply -f argocd-apps/observability.yaml
```
8. Access Grafana Dashboard
```bash
kubectl port-forward svc/grafana -n monitoring 3000:80
```

OPTIONAL PROMETHEUS EXPOSURE
```bash
# Expose both Grafana and Prometheus
export EXPOSE_PROMETHEUS=true
./scripts/setup.sh

# Expose only Grafana
export EXPOSE_PROMETHEUS=false
./scripts/setup.sh
```