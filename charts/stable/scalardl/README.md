# scalardl

Implementation scalardl.
Current chart version is `1.2.2`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| envoy.affinity | object | `{}` | the affinity/anti-affinity feature, greatly expands the types of constraints you can express |
| envoy.envoyConfiguration.adminAccessLogPath | string | `"/dev/stdout"` | admin log path |
| envoy.image.pullPolicy | string | `"IfNotPresent"` | Specify a imagePullPolicy |
| envoy.image.repository | string | `"ghcr.io/scalar-labs/scalar-envoy"` | Docker image |
| envoy.image.version | string | `"1.0.0"` |  |
| envoy.imagePullSecrets | list | `[]` | Optionally specify an array of imagePullSecrets. Secrets must be manually created in the namespace. |
| envoy.nodeSelector | object | `{}` | nodeSelector is form of node selection constraint |
| envoy.podSecurityContext | object | `{}` | PodSecurityContext holds pod-level security attributes and common container settings |
| envoy.prometheusRule.enabled | bool | `false` | enable rules for prometheus |
| envoy.prometheusRule.namespace | string | `"monitoring"` | which namespace prometheus is located. by default monitoring |
| envoy.replicaCount | int | `3` | number of replicas to deploy |
| envoy.resources | object | `{}` | resources allowed to the pod |
| envoy.securityContext | object | `{}` | Setting security context at the pod applies those settings to all containers in the pod |
| envoy.service.annotations | object | `{}` | Service annotations, e.g: prometheus, etc. |
| envoy.service.ports.envoy-priv.port | int | `50052` | nvoy public port |
| envoy.service.ports.envoy-priv.protocol | string | `"TCP"` | envoy protocol |
| envoy.service.ports.envoy-priv.targetPort | int | `50052` | envoy k8s internal name |
| envoy.service.ports.envoy.port | int | `50051` | envoy public port |
| envoy.service.ports.envoy.protocol | string | `"TCP"` | envoy protocol |
| envoy.service.ports.envoy.targetPort | int | `50051` | envoy k8s internal name |
| envoy.service.type | string | `"ClusterIP"` | service types in kubernetes |
| envoy.serviceMonitor.enabled | bool | `false` | enable metrics collect with prometheus |
| envoy.serviceMonitor.interval | string | `"15s"` | custom interval to retrieve the metrics |
| envoy.serviceMonitor.namespace | string | `"monitoring"` | which namespace prometheus is located. by default monitoring |
| envoy.strategy.rollingUpdate | object | `{"maxSurge":"25%","maxUnavailable":"25%"}` | The number of pods that can be unavailable during the update process |
| envoy.strategy.type | string | `"RollingUpdate"` | New pods are added gradually, and old pods are terminated gradually, e.g: Recreate or RollingUpdate |
| envoy.tolerations | list | `[]` | Tolerations are applied to pods, and allow (but do not require) the pods to schedule onto nodes with matching taints. |
| fullnameOverride | string | `""` | String to fully override scalardl.fullname template |
| ledger.affinity | object | `{}` | the affinity/anti-affinity feature, greatly expands the types of constraints you can express |
| ledger.existingSecret | string | `nil` | Name of existing secret to use for storing database username and password |
| ledger.image.pullPolicy | string | `"IfNotPresent"` | Specify a imagePullPolicy |
| ledger.image.repository | string | `"ghcr.io/scalar-labs/scalar-ledger"` | Docker image |
| ledger.image.version | string | `"2.1.0"` | Docker tag |
| ledger.imagePullSecrets | list | `[{"name":"reg-docker-secrets"}]` | Optionally specify an array of imagePullSecrets. Secrets must be manually created in the namespace. |
| ledger.nodeSelector | object | `{}` | nodeSelector is form of node selection constraint |
| ledger.podSecurityContext | object | `{}` | PodSecurityContext holds pod-level security attributes and common container settings |
| ledger.prometheusRule.enabled | bool | `false` | enable rules for prometheus |
| ledger.prometheusRule.namespace | string | `"monitoring"` | which namespace prometheus is located. by default monitoring |
| ledger.replicaCount | int | `3` | number of replicas to deploy |
| ledger.resources | object | `{}` | resources allowed to the pod |
| ledger.scalarLedgerConfiguration.dbContactPoints | string | `"cassandra"` | The contact points of the database such as hostnames or URLs |
| ledger.scalarLedgerConfiguration.dbContactPort | int | `9042` | The port number of the contact points |
| ledger.scalarLedgerConfiguration.dbPassword | string | `"cassandra"` | The password of the database |
| ledger.scalarLedgerConfiguration.dbStorage | string | `"cassandra"` | The storage of the database: cassandra or cosmos |
| ledger.scalarLedgerConfiguration.dbUsername | string | `"cassandra"` | The username of the database |
| ledger.scalarLedgerConfiguration.ledgerLogLevel | string | `"INFO"` | The log level of Scalar ledger |
| ledger.securityContext | object | `{}` | Setting security context at the pod applies those settings to all containers in the pod |
| ledger.service.annotations | object | `{}` |  |
| ledger.service.ports.scalardl-admin.port | int | `50053` | scalardl-admin target port |
| ledger.service.ports.scalardl-admin.protocol | string | `"TCP"` | scalardl-admin protocol |
| ledger.service.ports.scalardl-admin.targetPort | int | `50053` | scalardl-admin k8s internal name |
| ledger.service.ports.scalardl-priv.port | int | `50052` | scalardl-priv target port |
| ledger.service.ports.scalardl-priv.protocol | string | `"TCP"` | scalardl-priv protocol |
| ledger.service.ports.scalardl-priv.targetPort | int | `50052` | scalardl-priv k8s internal name |
| ledger.service.ports.scalardl.port | int | `50051` | scalardl target port |
| ledger.service.ports.scalardl.protocol | string | `"TCP"` | scalardl protocol |
| ledger.service.ports.scalardl.targetPort | int | `50051` | scalardl k8s internal name |
| ledger.service.type | string | `"ClusterIP"` | service types in kubernetes |
| ledger.strategy.rollingUpdate | object | `{"maxSurge":"25%","maxUnavailable":"25%"}` | The number of pods that can be unavailable during the update process |
| ledger.strategy.type | string | `"RollingUpdate"` | New pods are added gradually, and old pods are terminated gradually, e.g: Recreate or RollingUpdate |
| ledger.tolerations | list | `[]` | Tolerations are applied to pods, and allow (but do not require) the pods to schedule onto nodes with matching taints. |
| nameOverride | string | `""` | String to partially override scalardl.fullname template (will maintain the release name) |
