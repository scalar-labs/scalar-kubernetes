scalar-envoy
============
Implementation of Envoy for scalar-ledger. Envoy is an open source edge and service proxy, designed for cloud-native applications.

Current chart version is `0.1.0`

Source code can be found [here](https://www.envoyproxy.io/)



## Chart Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| files."envoy.yaml" | string | `"admin:\n  access_log_path: /dev/stdout\n  address:\n    socket_address:\n      address: 0.0.0.0\n      port_value: 9901\nstatic_resources:\n  listeners:\n  - name: listener_0\n    address:\n      socket_address:\n        address: 0.0.0.0\n        port_value: 50051\n    filter_chains:\n    - filters:\n      - name: envoy.http_connection_manager\n        config:\n          codec_type: auto\n          stat_prefix: ingress_http\n          route_config:\n            name: local_route\n            virtual_hosts:\n            - name: local_service\n              domains: [\"*\"]\n              routes:\n              - match: { prefix: \"/\" }\n                route: { cluster: scalar-ledger }\n              cors:\n                allow_origin_string_match:\n                  - safe_regex:\n                      google_re2: {}\n                      regex: \\*\n                allow_methods: GET, PUT, DELETE, POST, OPTIONS\n                allow_headers: keep-alive,user-agent,cache-control,content-type,content-transfer-encoding,custom-header-1,x-accept-content-transfer-encoding,x-accept-response-streaming,x-user-agent,x-grpc-web,grpc-timeout\n                max_age: \"1728000\"\n                expose_headers: custom-header-1,grpc-status,grpc-message,rpc.status-bin\n          http_filters:\n          - name: envoy.grpc_web\n          - name: envoy.cors\n          - name: envoy.router\n  - name: listener_1\n    address:\n      socket_address:\n        address: 0.0.0.0\n        port_value: 50052\n    filter_chains:\n    - filters:\n      - name: envoy.http_connection_manager\n        config:\n          codec_type: auto\n          stat_prefix: ingress_http\n          route_config:\n            name: local_route\n            virtual_hosts:\n            - name: local_service\n              domains: [\"*\"]\n              routes:\n              - match: { prefix: \"/\" }\n                route: { cluster: scalar-ledger-privileged }\n              cors:\n                allow_origin_string_match:\n                  - safe_regex:\n                      google_re2: {}\n                      regex: \\*\n                allow_methods: GET, PUT, DELETE, POST, OPTIONS\n                allow_headers: keep-alive,user-agent,cache-control,content-type,content-transfer-encoding,custom-header-1,x-accept-content-transfer-encoding,x-accept-response-streaming,x-user-agent,x-grpc-web,grpc-timeout\n                max_age: \"1728000\"\n                expose_headers: custom-header-1,grpc-status,grpc-message,rpc.status-bin\n          http_filters:\n          - name: envoy.grpc_web\n          - name: envoy.cors\n          - name: envoy.router\n  clusters:\n  - name: scalar-ledger\n    connect_timeout: 0.25s\n    type: strict_dns\n    lb_policy: round_robin\n    hosts:\n      socket_address:\n        address: scalar-ledger-headless\n        port_value: 50051\n    health_checks:\n      - timeout: 1s\n        interval: 5s\n        interval_jitter: 1s\n        unhealthy_threshold: 3\n        healthy_threshold: 3\n        grpc_health_check: {}\n    http2_protocol_options: {}\n    drain_connections_on_host_removal: true\n  - name: scalar-ledger-privileged\n    connect_timeout: 0.25s\n    type: strict_dns\n    lb_policy: round_robin\n    hosts:\n      socket_address:\n        address: scalar-ledger-headless\n        port_value: 50052\n    health_checks:\n      - timeout: 1s\n        interval: 5s\n        interval_jitter: 1s\n        unhealthy_threshold: 3\n        healthy_threshold: 3\n        grpc_health_check: {}\n    http2_protocol_options: {}\n    drain_connections_on_host_removal: true"` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"envoyproxy/envoy"` |  |
| image.tag | string | `"v1.12.2"` |  |
| imagePullSecrets | list | `[]` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podDisruptionBudget | string | `"maxUnavailable: 1\n"` |  |
| podSecurityContext | object | `{}` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| service.annotations | object | `{}` |  |
| service.ports.envoy-priv.port | int | `50052` |  |
| service.ports.envoy-priv.protocol | string | `"TCP"` |  |
| service.ports.envoy-priv.targetPort | string | `"envoy-priv"` |  |
| service.ports.envoy.port | int | `50051` |  |
| service.ports.envoy.protocol | string | `"TCP"` |  |
| service.ports.envoy.targetPort | string | `"envoy"` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceMonitor.additionalLabels | object | `{}` |  |
| serviceMonitor.enabled | bool | `false` |  |
| serviceMonitor.interval | string | `"15s"` |  |
| serviceMonitor.podTargetLabels | list | `[]` |  |
| serviceMonitor.targetLabels | list | `[]` |  |
| strategy.rollingUpdate.maxSurge | int | `0` |  |
| strategy.rollingUpdate.maxUnavailable | int | `1` |  |
| strategy.type | string | `"RollingUpdate"` |  |
| tolerations | list | `[]` |  |
