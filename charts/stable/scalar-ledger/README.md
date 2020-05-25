scalar-ledger
=============
A Helm chart for Kubernetes Scalar Ledger

Current chart version is `0.1.0`

Source code can be found [here](https://scalar-labs.com/)



## Chart Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| cassandra.host | string | `"cassandra"` |  |
| cassandra.password | string | `"cassandra"` |  |
| cassandra.port | int | `9042` |  |
| cassandra.user | string | `"cassandra"` |  |
| files."init.cql" | string | `"CREATE KEYSPACE IF NOT EXISTS scalar WITH replication = {'class': 'NetworkTopologyStrategy', 'dc1': 1 };\nCREATE KEYSPACE IF NOT EXISTS coordinator WITH replication = {'class': 'NetworkTopologyStrategy', 'dc1': 1 };\nALTER KEYSPACE system_auth WITH replication = {'class': 'NetworkTopologyStrategy', 'dc1': 1 };\nCREATE TABLE IF NOT EXISTS scalar.asset (\n    id text,\n    age int,\n    argument text,\n    before_argument text,\n    before_contract_id text,\n    before_hash blob,\n    before_input text,\n    before_output text,\n    before_prev_hash blob,\n    before_signature blob,\n    before_tx_committed_at bigint,\n    before_tx_id text,\n    before_tx_prepared_at bigint,\n    before_tx_state int,\n    before_tx_version int,\n    contract_id text,\n    hash blob,\n    input text,\n    output text,\n    prev_hash blob,\n    signature blob,\n    tx_committed_at bigint,\n    tx_id text,\n    tx_prepared_at bigint,\n    tx_state int,\n    tx_version int,\n    PRIMARY KEY (id, age)\n) WITH compaction = { 'class' : 'LeveledCompactionStrategy' };\nCREATE TABLE IF NOT EXISTS scalar.asset_metadata (\n    asset_id text,\n    latest_age int,\n    PRIMARY KEY (asset_id)\n) WITH compaction = { 'class' : 'LeveledCompactionStrategy' };\nCREATE TABLE IF NOT EXISTS scalar.contract (\n    id text,\n    cert_holder_id text,\n    cert_version int,\n    binary_name text,\n    properties text,\n    registered_at bigint,\n    signature blob,\n    PRIMARY KEY (cert_holder_id, cert_version, id)\n) WITH compaction = { 'class' : 'LeveledCompactionStrategy' };\nCREATE INDEX IF NOT EXISTS ON scalar.contract (id);\nCREATE TABLE IF NOT EXISTS scalar.contract_class (\n    binary_name text,\n    byte_code blob,\n    PRIMARY KEY (binary_name)\n);\nCREATE TABLE IF NOT EXISTS scalar.function (\n    id text,\n    binary_name text,\n    byte_code blob,\n    registered_at bigint,\n    PRIMARY KEY (id)\n) WITH compaction = { 'class' : 'LeveledCompactionStrategy' };\nCREATE TABLE IF NOT EXISTS scalar.certificate (\n    holder_id text,\n    version int,\n    pem text,\n    registered_at bigint,\n    PRIMARY KEY (holder_id, version)\n);\nCREATE TABLE IF NOT EXISTS coordinator.state (\n    tx_id text,\n    tx_state int,\n    tx_created_at bigint,\n    PRIMARY KEY (tx_id)\n);\n"` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"scalarlabs/scalar-ledger"` |  |
| image.tag | string | `"2.0.5"` |  |
| imagePullSecrets[0].name | string | `"reg-docker-secrets"` |  |
| initContainer.enabled | bool | `true` |  |
| initContainer.image.pullPolicy | string | `"IfNotPresent"` |  |
| initContainer.image.repository | string | `"cassandra"` |  |
| initContainer.image.tag | string | `"latest"` |  |
| initContainer.waitCassandra | int | `20` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podDisruptionBudget | string | `"maxUnavailable: 1\n"` |  |
| podSecurityContext | object | `{}` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| service.clusterIP | string | `"None"` |  |
| service.name | string | `"scalar-ledger-headless"` |  |
| service.type | string | `"ClusterIP"` |  |
| strategy.rollingUpdate.maxSurge | int | `0` |  |
| strategy.rollingUpdate.maxUnavailable | int | `1` |  |
| strategy.type | string | `"RollingUpdate"` |  |
| tolerations | list | `[]` |  |
