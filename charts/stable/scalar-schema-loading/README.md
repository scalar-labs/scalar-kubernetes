schema-loading
=====================

Implementation schema loading for scalar-ledger
Current chart version is `1.0.0`

## Chart Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cassandra.enabled | bool | `true` |  |
| cassandra.image.pullPolicy | string | `"IfNotPresent"` | Specify a imagePullPolicy |
| cassandra.image.repository | string | `"scalarlabs/scalar-ledger"` | Docker image |
| cassandra.image.version | string | `"2.0.7"` |  |
| cassandra.imagePullSecrets | list | `[{"name":"reg-docker-secrets"}]` | Optionally specify an array of imagePullSecrets. Secrets must be manually created in the namespace. |
| cassandra.scalarLedgerConfiguration.cassandraHost | string | `"cassandra"` |  |
| cassandra.scalarLedgerConfiguration.cassandraPassword | string | `"cassandra"` |  |
| cassandra.scalarLedgerConfiguration.cassandraPort | int | `9042` |  |
| cassandra.scalarLedgerConfiguration.cassandraUsername | string | `"cassandra"` |  |
| cassandra.scalarLedgerConfiguration.ledgerLogLevel | string | `"INFO"` |  |
| cassandra.scalarLedgerConfiguration.replicationFactor | int | `3` |  |
