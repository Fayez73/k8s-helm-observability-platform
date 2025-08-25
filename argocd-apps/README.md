## ArgoCD deployment


1. GitOps with Argo CD (optional)
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
2. Expose Argo CD server (for local access):
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
3. Login to ArgoCD cli
```bash
# Get the initial password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d; echo

# Login
argocd login localhost:8080 --username admin --password <password> --insecure
```
4. Apply the app found in argocd-apps directory
```bash
kubectl apply -f argocd-apps/observability.yaml
```