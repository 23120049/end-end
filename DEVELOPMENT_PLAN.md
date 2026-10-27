# Development Plan

## Goal

Build a deliberately small Nginx release page and use it to learn an end-to-end DevOps delivery platform. The page is not the point: the project demonstrates how a workload is built, validated, promoted, deployed, observed, secured, and rolled back.

The project starts locally on an 8 GB PC and later moves its lightweight deployment path to AWS. The full service-mesh, security-analysis, logging, metrics, and tracing demonstrations remain local because they are too resource-intensive for a free-tier cloud VM.

## Constraints

- Local machine: 8 GB RAM. Run only one advanced profile at a time.
- Cloud: free-tier or available AWS credits only. Verify account eligibility in the AWS console before applying Terraform.
- AWS: one minimal EC2 instance running k3s. Do not use EKS, NAT Gateway, load balancers, managed databases, or managed Elasticsearch.
- Deployment: Argo CD is the only component that applies application manifests. CI updates Git; it does not deploy directly to Kubernetes.

## Runtime Profiles

| Profile | Purpose | Components | Rule |
| --- | --- | --- | --- |
| `base` | Daily development and GitOps | k3s, Argo CD, Helm, Nginx, ingress | Keep below roughly 3 GB RAM. |
| `mesh` | Service-mesh lab | Base + Istio + Kiali + a small internal test workload | Run only while collecting mesh evidence. |
| `observability` | Metrics, logs, and traces lab | Base + OpenTelemetry Collector + Prometheus + Grafana + Loki + Tempo + lightweight exporters/probe | Run separately from mesh and ELK. |
| `logging` | Centralized logging lab | Base + Elasticsearch + Logstash + Kibana | Run only while collecting logging evidence. |

## Milestones

### 1. Minimal workload

- Create a static Nginx page that exposes a release version, Git commit SHA, and image creation timestamp.
- Add a `/health` endpoint and a local smoke-test script.
- Keep application behavior intentionally small and deterministic.

**Done when:** the page and health endpoint run locally without Kubernetes.

### 2. Container delivery

- Create a small, reproducible Docker image.
- Pass release metadata through build arguments or generated static content.
- Tag images immutably with the commit SHA; never promote `latest` as a deployment reference.
- Publish the image to a registry.

**Done when:** a chosen image tag serves the matching release metadata.

### 3. Repository and CI quality gates

- Protect `main`; require pull requests and successful checks before merging.
- On pull requests, validate HTML, Nginx configuration, Dockerfile, Helm, Kubernetes manifests, and Terraform.
- Run SonarCloud analysis and enforce its quality gate; use it for static-page assets and any automation scripts introduced by the project.
- Scan for secrets with Gitleaks, Dockerfiles with Hadolint, images/IaC with Trivy, and Terraform/Kubernetes policies with Checkov or an equivalent policy scanner.
- On merge to `main`, build, scan, publish the commit-SHA image, and update the GitOps image reference through a commit or pull request.
- On semantic release tags, promote an existing immutable image to staging configuration.

**Done when:** an invalid configuration blocks a pull request and a merge creates a traceable image release.

### 4. Local k3s and GitOps

- Install a single-node local k3s cluster.
- Package the Nginx workload as a Helm chart with deployment, service, ingress/gateway, health probes, resource limits, and configurable image tag.
- Create `dev` and `staging` namespaces; add short-lived preview namespaces for feature work.
- Install Argo CD and register the GitOps source.
- Make Argo CD synchronize the Helm release; deploy and roll back only by changing Git.

**Done when:** changing the GitOps image tag updates the running page and reverting that Git change rolls it back.

### 5. Service-mesh lab

- Enable Istio injection for the lab namespace and install Kiali.
- Use strict mTLS for in-mesh traffic.
- Add a small internal test workload solely for demonstrating allowed/denied traffic and retries; the public workload remains the Nginx page.
- Define `AuthorizationPolicy`, timeout/retry rules, and a canary traffic split between two Nginx image versions.
- Capture Kiali topology, traffic split, policy test output, and rollback evidence.

**Done when:** a controlled request split reaches two versions and Kiali shows healthy traffic.

### 6. OpenTelemetry and Grafana observability lab

- Use an OpenTelemetry Collector as the vendor-neutral telemetry entry point.
- Scrape Nginx and Kubernetes metrics with Prometheus; create Grafana dashboards for availability, request rate, latency, error rate, and rollout health.
- Send logs to Loki and search them through Grafana.
- Send traces from a small telemetry-probe workload, and from mesh traffic when the mesh lab is active, to Tempo.
- Correlate metrics, logs, and traces in Grafana using release version, environment, and trace identifiers where available.

**Done when:** a synthetic request can be followed from a Grafana metric to its Loki log entry and Tempo trace.

### 7. ELK logging lab

- Configure Nginx access and error logs for structured collection.
- Deploy Elasticsearch, Logstash, and Kibana with conservative resource limits and low data retention.
- Ingest Nginx logs and Kubernetes events.
- Create dashboards for request volume, HTTP errors, rollout events, and health-check failures.

**Done when:** a generated error is searchable in Kibana and appears in an error dashboard.

### 8. AWS evolution

- Preflight the account's active Free Tier/credit eligibility and set a budget alert before provisioning.
- Use Terraform for minimal EC2 networking, security group, IAM, instance, tags, and state storage.
- Use Ansible to harden the host, install k3s, and bootstrap the lightweight GitOps stack.
- Deploy the same Helm chart and immutable image through Argo CD.
- Verify the public endpoint, GitOps sync, and Git-based rollback; destroy all cloud resources after the demonstration.

**Done when:** AWS serves the same release from the same GitOps source, then Terraform removes the created infrastructure.

## Evidence Checklist

- An open pull request with required checks.
- Successful and failed GitHub Actions runs.
- SonarCloud quality-gate result; Gitleaks, Hadolint, Trivy, and IaC-policy scan results.
- Registry image tagged with a commit SHA.
- Argo CD healthy/synced application view.
- Dev, staging, preview, canary, and rollback proof.
- Kiali topology and mTLS/authorization/retry test output.
- Grafana dashboards plus correlated Prometheus metrics, Loki logs, and Tempo traces.
- Kibana dashboards and searchable failure logs.
- Terraform plan/apply/destroy evidence and AWS billing/Free Tier preflight screenshot.

## Completion Standard

The project is complete when another developer can clone the repository, understand the architecture from `README.md`, run the base profile locally, reproduce a GitOps deployment and rollback, start either advanced lab, and follow the AWS runbook without receiving credentials from the repository.
