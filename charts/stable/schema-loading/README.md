# schema-loading

Implementation schema loading for scalar-ledger
Current chart version is `1.1.0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| schemaLoading.contactPoints | string | `"cassandra"` |  |
| schemaLoading.contactPort | int | `9042` |  |
| schemaLoading.database | string | `"cassandra"` |  |
| schemaLoading.image.pullPolicy | string | `"IfNotPresent"` | Specify a imagePullPolicy |
| schemaLoading.image.repository | string | `"scalarlabs/scalardl-schema-loader-cassandra"` | Docker image |
| schemaLoading.image.version | string | `"1.0.0"` |  |
| schemaLoading.imagePullSecrets | list | `[{"name":"reg-docker-secrets"}]` | Optionally specify an array of imagePullSecrets. Secrets must be manually created in the namespace. |
| schemaLoading.password | string | `"cassandra"` |  |
| schemaLoading.replicationFactor | int | `3` |  |
| schemaLoading.username | string | `"cassandra"` |  |
