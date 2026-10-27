# nginx-page Helm chart

This chart deploys the Nginx release page with a `ClusterIP` Service, health
probes, resource requests/limits, and optional Ingress, HPA, ServiceAccount,
image-pull secrets, and scheduling configuration.

## Validate and install

```bash
helm lint ./Helm
helm template nginx-page ./Helm
helm upgrade --install nginx-page ./Helm --namespace default
```

If you previously applied the root `deployment.yaml`, delete those legacy
resources before the first Helm installation. Helm must own the resources it
manages, and a Deployment selector cannot be changed in place:

```bash
kubectl delete -f deployment.yaml
helm upgrade --install nginx-page ./Helm --namespace default
```

For a Docker Hub image, set the repository and immutable tag at deployment
time rather than editing templates:

```bash
helm upgrade --install nginx-page ./Helm \
  --set image.repository=YOUR_DOCKERHUB_USERNAME/nginx-server \
  --set image.tag=COMMIT_SHA
```

The chart defaults to `ClusterIP`. For local access, run:

```bash
kubectl port-forward service/nginx-page-nginx-page 8080:80
```

To enable K3s Traefik Ingress, provide an override file such as:

```yaml
ingress:
  enabled: true
  className: traefik
  hosts:
    - host: nginx-page.local
      paths:
        - path: /
          pathType: Prefix
```
