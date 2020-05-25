scalar-ledger
=============
A Helm chart for Kubernetes Scalar Ledger

Current chart version is `0.1.0`

Source code can be found [here](https://scalar-labs.com/)



## Chart Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | the affinity/anti-affinity feature, greatly expands the types of constraints you can express |
| cassandra.host | string | `"cassandra"` |  |
| cassandra.password | string | `"cassandra"` |  |
| cassandra.port | int | `9042` |  |
| cassandra.user | string | `"cassandra"` |  |
| files."init.cql" | string | `"CREATE KEYSPACE IF NOT EXISTS scalar WITH replication = {'class': 'NetworkTopologyStrategy', 'dc1': 1 };\nCREATE KEYSPACE IF NOT EXISTS coordinator WITH replication = {'class': 'NetworkTopologyStrategy', 'dc1': 1 };\nALTER KEYSPACE system_auth WITH replication = {'class': 'NetworkTopologyStrategy', 'dc1': 1 };\nCREATE TABLE IF NOT EXISTS scalar.asset (\n    id text,\n    age int,\n    argument text,\n    before_argument text,\n    before_contract_id text,\n    before_hash blob,\n    before_input text,\n    before_output text,\n    before_prev_hash blob,\n    before_signature blob,\n    before_tx_committed_at bigint,\n    before_tx_id text,\n    before_tx_prepared_at bigint,\n    before_tx_state int,\n    before_tx_version int,\n    contract_id text,\n    hash blob,\n    input text,\n    output text,\n    prev_hash blob,\n    signature blob,\n    tx_committed_at bigint,\n    tx_id text,\n    tx_prepared_at bigint,\n    tx_state int,\n    tx_version int,\n    PRIMARY KEY (id, age)\n) WITH compaction = { 'class' : 'LeveledCompactionStrategy' };\nCREATE TABLE IF NOT EXISTS scalar.asset_metadata (\n    asset_id text,\n    latest_age int,\n    PRIMARY KEY (asset_id)\n) WITH compaction = { 'class' : 'LeveledCompactionStrategy' };\nCREATE TABLE IF NOT EXISTS scalar.contract (\n    id text,\n    cert_holder_id text,\n    cert_version int,\n    binary_name text,\n    properties text,\n    registered_at bigint,\n    signature blob,\n    PRIMARY KEY (cert_holder_id, cert_version, id)\n) WITH compaction = { 'class' : 'LeveledCompactionStrategy' };\nCREATE INDEX IF NOT EXISTS ON scalar.contract (id);\nCREATE TABLE IF NOT EXISTS scalar.contract_class (\n    binary_name text,\n    byte_code blob,\n    PRIMARY KEY (binary_name)\n);\nCREATE TABLE IF NOT EXISTS scalar.function (\n    id text,\n    binary_name text,\n    byte_code blob,\n    registered_at bigint,\n    PRIMARY KEY (id)\n) WITH compaction = { 'class' : 'LeveledCompactionStrategy' };\nCREATE TABLE IF NOT EXISTS scalar.certificate (\n    holder_id text,\n    version int,\n    pem text,\n    registered_at bigint,\n    PRIMARY KEY (holder_id, version)\n);\nCREATE TABLE IF NOT EXISTS coordinator.state (\n    tx_id text,\n    tx_state int,\n    tx_created_at bigint,\n    PRIMARY KEY (tx_id)\n);\n"` |  |
| fullnameOverride | string | `""` | String to fully override scalar-envoy.fullname template |
| image.pullPolicy | string | `"IfNotPresent"` | Specify a imagePullPolicy |
| image.repository | string | `"scalarlabs/scalar-ledger"` | Docker image |
| image.tag | string | `"2.0.5"` | Docker image tag, e.g: latest or specific version |
| imagePullSecrets | list | `[{"name":"reg-docker-secrets"}]` | Optionally specify an array of imagePullSecrets. Secrets must be manually created in the namespace. |
| initContainer.enabled | bool | `true` | to enabled cassandra keyspace creation  |
| initContainer.image.pullPolicy | string | `"IfNotPresent"` |  |
| initContainer.image.repository | string | `"cassandra"` | Docker image tag, e.g: latest or specific version |
| initContainer.image.tag | string | `"latest"` |  |
| initContainer.waitCassandra | int | `20` | number of second before talk to cassandra for keyspace creation |
| nameOverride | string | `""` | String to partially override scalar-envoy.fullname template (will maintain the release name) |
| nodeSelector | object | `{}` | nodeSelector is form of node selection constraint |
| podDisruptionBudget | string | `"maxUnavailable: 1\n"` | podDisruptionBudget Settings |
| podSecurityContext | object | `{}` | PodSecurityContext holds pod-level security attributes and common container settings |
| replicaCount | int | `1` | number of replicas to deploy |
| resources | object | `{}` | resources allowed to the pod |
| securityContext | object | `{}` | Setting security context at the pod applies those settings to all containers in the pod |
| service.clusterIP | string | `"None"` | to make sure it is a headless service |
| service.name | string | `"scalar-ledger-headless"` | svc name need to be know for share with envoy |
| service.type | string | `"ClusterIP"` | service types in kubernetes |
| strategy.rollingUpdate | object | `{"maxSurge":0,"maxUnavailable":1}` | The number of pods that can be unavailable during the update process |
| strategy.type | string | `"RollingUpdate"` | New pods are added gradually, and old pods are terminated gradually, e.g: Recreate or RollingUpdate |
| tolerations | list | `[]` | Tolerations are applied to pods, and allow (but do not require) the pods to schedule onto nodes with matching taints. |
