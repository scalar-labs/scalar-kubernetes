scalar-ledger
=============
A Helm chart for Kubernetes Scalar Ledger
Current chart version is `1.0.0`

## Chart Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | the affinity/anti-affinity feature, greatly expands the types of constraints you can express |
| fullnameOverride | string | `""` | String to fully override scalar-envoy.fullname template |
| image.pullPolicy | string | `"IfNotPresent"` | Specify a imagePullPolicy |
| image.repository | string | `"scalarlabs/scalar-ledger"` | Docker image |
| imagePullSecrets | list | `[]` | Optionally specify an array of imagePullSecrets. Secrets must be manually created in the namespace. |
| nameOverride | string | `""` | String to partially override scalar-envoy.fullname template (will maintain the release name) |
| nodeSelector | object | `{}` | nodeSelector is form of node selection constraint |
| podSecurityContext | object | `{}` | PodSecurityContext holds pod-level security attributes and common container settings |
| replicaCount | int | `3` | number of replicas to deploy |
| resources | object | `{}` | resources allowed to the pod |
| scalarLedgerConfiguration.cassandraHost | string | `"cassandra"` |  |
| scalarLedgerConfiguration.cassandraPassword | string | `"cassandra"` |  |
| scalarLedgerConfiguration.cassandraPort | int | `9042` |  |
| scalarLedgerConfiguration.cassandraUsername | string | `"cassandra"` |  |
| scalarLedgerConfiguration.ledgerLogLevel | string | `"INFO"` |  |
| securityContext | object | `{}` | Setting security context at the pod applies those settings to all containers in the pod |
| service.type | string | `"ClusterIP"` | service types in kubernetes |
| strategy.rollingUpdate | object | `{"maxSurge":0,"maxUnavailable":1}` | The number of pods that can be unavailable during the update process |
| strategy.type | string | `"RollingUpdate"` | New pods are added gradually, and old pods are terminated gradually, e.g: Recreate or RollingUpdate |
| tolerations | list | `[]` | Tolerations are applied to pods, and allow (but do not require) the pods to schedule onto nodes with matching taints. |