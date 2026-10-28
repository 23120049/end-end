# Argo CD applications

After Argo CD is installed in the `argocd` namespace, bootstrap the local
deployments once:

```bash
kubectl apply -f argocd/dev.yaml
kubectl apply -f argocd/staging.yaml
kubectl apply -f argocd/previews.yaml
```

The dev and staging Applications read their environment values from `Helm/`.

The preview ApplicationSet creates one Application and namespace for every
`Helm/previews/pr-<number>.yaml` file. Removing that file deletes the preview
Application and its resources.
