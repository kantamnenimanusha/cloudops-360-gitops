# cloudops-360-gitops

Desired state of the CloudOps 360 cluster. **Argo CD watches this repository**; Jenkins only ever changes one line here
(the `image.tag` of one app) after a build passes its quality and security gates.

```
argocd/                         AppProject + the "root" Application (one per environment) - applied once by scripts
charts/argocd-apps/             app-of-apps: renders every Argo CD Application for an environment
charts/cloudops-app/            ONE hardened chart reused by all 4 workloads (release name = app name)
charts/cluster-config/          cloudops namespace (Pod Security labels) + read-only ServiceAccount for Jenkins
charts/observability-extras/    Loki, Alloy, Jaeger, PrometheusRule alerts, Grafana dashboard
envs/local/  envs/aws/          values per environment (image repository + tag, env vars, third-party chart values)
```

## Before first use
`scripts\windows\01-configure.ps1` (in the app repo) replaces `__GITHUB_USER__` everywhere with your GitHub user name. For AWS,
`aws-configure-gitops.ps1` replaces `__ECR_REGISTRY__`, `__AWS_REGION__`, `__BACKEND_ROLE_ARN__`, `__CI_SERVER_PRIVATE_IP__` in `envs/aws/`.
Do not hand-edit `image.tag` lines: Jenkins rewrites them (`sed` expects exactly one `tag:` line per workload file).

## Sync order and pinning
Applications are annotated with sync waves (0: cluster-config, kube-prometheus-stack, metrics-server; 1: observability-extras; 2: workloads).
Argo CD does not wait for child Applications by default, so ordering is enforced mostly by automatic retries (`retry` with backoff):
transient "no matches for kind ServiceMonitor" errors during the first sync are expected and clear themselves.
Third-party chart versions are `*` in `charts/argocd-apps/values.yaml` - pin them after your first successful sync (see `docs/VERSIONS.md` in the app repo).

## Rollback
`git revert <commit>` + push. Argo CD re-deploys the previous tag and records it in its history.

## Secrets
None live here. Kubernetes Secrets (`cloudops-backend-secrets`, `chaos-secrets`, `alertmanager-webhook-token`) are created by
`scripts\windows\06-bootstrap-gitops.ps1` from git-ignored local files.
