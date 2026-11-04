# nginx-page Helm chart

This chart deploys the Nginx release page and private Node.js API with
`ClusterIP` Services, health probes, resource requests/limits, a ConfigMap
mounted into Nginx, and default-deny NetworkPolicies. Development uses two web
replicas and a Traefik IngressRoute at `nginx-page.local`; staging uses
`staging.nginx-page.local`.

The cluster must have Traefik's `IngressRoute` CRD and Kubernetes CRD provider
enabled before Argo CD synchronizes this chart. Check with
`kubectl get crd ingressroutes.traefik.io`. Argo CD's pruning removes the old
standard Ingress after the new chart is committed and synchronized.

## Validate and deploy

```bash
helm lint ./Helm
helm template nginx-page ./Helm --namespace dev -f Helm/values-dev.yaml
```

If you previously applied the root `deployment.yaml`, delete those legacy
resources before the first Argo CD sync. The old Deployment selector cannot
be changed in place:

```bash
kubectl delete -f deployment.yaml
kubectl apply -f argocd/dev.yaml
```

Argo CD owns application deployment. To change a release, commit the same
immutable SHA for the web and API image tags in the environment values file:

```yaml
image:
  tag: COMMIT_SHA
api:
  image:
    tag: COMMIT_SHA
```

The chart defaults to `ClusterIP`. For local access, run:

```bash
kubectl -n dev port-forward service/nginx-page 8080:80
```

Development and staging values enable Traefik IngressRoute on the `web` entry
point. Its `nativeLB` setting routes through the web Service ClusterIP. To test the route from
outside the cluster, use a reachable node IP and the configured host header:

```bash
curl -H 'Host: nginx-page.local' http://NODE_IP/
```
