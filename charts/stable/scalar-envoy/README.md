scalar-envoy
============
Implementation of Envoy for scalar-ledger. Envoy is an open source edge and service proxy, designed for cloud-native applications.
Current chart version is `1.0.0`

## Chart Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | the affinity/anti-affinity feature, greatly expands the types of constraints you can express |
| envoyConfiguration.adminAccessLogPath | string | `"/dev/stdout"` | admin log path |
| envoyConfiguration.scalardlAddress | string | `"scalar-ledger-headless.default.svc.cluster.local"` | scalardl endpoint |
| fullnameOverride | string | `""` | String to fully override scalar-envoy.fullname template |
| image.pullPolicy | string | `"IfNotPresent"` | Specify a imagePullPolicy |
| image.repository | string | `"scalarlabs/scalar-envoy"` | Docker image |
| imagePullSecrets | list | `[]` | Optionally specify an array of imagePullSecrets. Secrets must be manually created in the namespace. |
| nameOverride | string | `""` | String to partially override scalar-envoy.fullname template (will maintain the release name) |
| nodeSelector | object | `{}` | nodeSelector is form of node selection constraint |
| podSecurityContext | object | `{}` | PodSecurityContext holds pod-level security attributes and common container settings |
| replicaCount | int | `3` | number of replicas to deploy |
| resources | object | `{}` | resources allowed to the pod |
| securityContext | object | `{}` | Setting security context at the pod applies those settings to all containers in the pod |
| service.annotations | object | `{}` | Service annotations, e.g: prometheus, etc. |
| service.ports.envoy-priv.port | int | `50052` | nvoy public port |
| service.ports.envoy-priv.protocol | string | `"TCP"` | envoy protocol |
| service.ports.envoy-priv.targetPort | int | `50052` | envoy k8s internal name |
| service.ports.envoy.port | int | `50051` | envoy public port |
| service.ports.envoy.protocol | string | `"TCP"` | envoy protocol |
| service.ports.envoy.targetPort | int | `50051` | envoy k8s internal name |
| service.type | string | `"LoadBalancer"` | service types in kubernetes |
| serviceMonitor.enabled | bool | `true` | enable metrics collect with prometheus |
| serviceMonitor.interval | string | `"15s"` | custom interval to retrieve the metrics |
| serviceMonitor.namespace | string | `"monitoring"` | which namespace prometheus is located. by default monitoring |
| strategy.rollingUpdate | object | `{"maxSurge":0,"maxUnavailable":1}` | The number of pods that can be unavailable during the update process |
| strategy.type | string | `"RollingUpdate"` | New pods are added gradually, and old pods are terminated gradually, e.g: Recreate or RollingUpdate |
| tolerations | list | `[]` | Tolerations are applied to pods, and allow (but do not require) the pods to schedule onto nodes with matching taints. |
