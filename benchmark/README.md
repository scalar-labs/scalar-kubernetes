# How to run a benchmark with kelpie for Scalar DL in Kubernetes

This document explains how to run a benchmark to verify the performance of Scalar DL in Kubernetes.

## Requirements

* Have completed:
  * [How to install Kubernetes CLI and Helm on the bastion](../docs/PrepareBastionTool.md)
  * [How to Deploy Scalar DL on Azure AKS](../docs/ScalarDLonAzureAKS.md)

## Docker

```console
docker build -t <user>/kelpie:latest ../docker/
docker push  <user>/kelpie:latest
```

## Configuration

Edit in local the file `benchmark-config.toml` and create the configmap

```console
$ kubectl create cm kelpie-config --from-file=benchmark-config.toml
configmap/kelpie-config created
```

## Pre load data in cassandra

```console
kubectl create -f kelpie-only-pre.yaml
job.batch/scalar-kelpie created
```

check if the job is `Completed`

```console
$ kubectl get po
NAME                             READY   STATUS              RESTARTS   AGE
scalar-envoy-7dc48c76bb-26ndc    1/1     Running             0          6m26s
scalar-envoy-7dc48c76bb-jx5nx    1/1     Running             0          6m26s
scalar-envoy-7dc48c76bb-qsr9b    1/1     Running             0          6m26s
scalar-kelpie-5ztph              0/1     ContainerCreating   0          5s
scalar-ledger-6db6689f86-2fqfk   1/1     Running             0          6m40s
scalar-ledger-6db6689f86-4pccj   1/1     Running             0          6m40s
scalar-ledger-6db6689f86-9nvjn   1/1     Running             0          6m40s
scalardl-schema-5jd5v            0/1     Completed           0          7m31s
```

few minute later on

```console
$ kubectl get po
NAME                             READY   STATUS              RESTARTS   AGE
scalar-envoy-7dc48c76bb-26ndc    1/1     Running             0          21m
scalar-envoy-7dc48c76bb-jx5nx    1/1     Running             0          21m
scalar-envoy-7dc48c76bb-qsr9b    1/1     Running             0          21m
scalar-kelpie-5ztph              0/1     Completed           0          15m
scalar-ledger-6db6689f86-2fqfk   1/1     Running             0          21m
scalar-ledger-6db6689f86-4pccj   1/1     Running             0          21m
scalar-ledger-6db6689f86-9nvjn   1/1     Running             0          21m
scalardl-schema-5jd5v            0/1     Completed           0          22m
```

## Run test

```console
$ kubectl create -f kelpie-run.yaml
job.batch/scalar-kelpie-run created
$ kubectl get po -o wide
NAME                             READY   STATUS      RESTARTS   AGE     IP             NODE                                   NOMINATED NODE   READINESS GATES
scalar-envoy-7dc48c76bb-26ndc    1/1     Running     0          30m     10.42.41.70    aks-scalardlpool-34802672-vmss000000   <none>           <none>
scalar-envoy-7dc48c76bb-jx5nx    1/1     Running     0          30m     10.42.41.158   aks-scalardlpool-34802672-vmss000001   <none>           <none>
scalar-envoy-7dc48c76bb-qsr9b    1/1     Running     0          30m     10.42.42.65    aks-scalardlpool-34802672-vmss000002   <none>           <none>
scalar-kelpie-5ztph              0/1     Completed   0          23m     10.42.40.71    aks-default-34802672-vmss000000        <none>           <none>
scalar-kelpie-run-8m7rf          1/1     Running     0          8m41s   10.42.40.76    aks-default-34802672-vmss000000        <none>           <none>
scalar-kelpie-run-fn76n          1/1     Running     0          8m41s   10.42.40.251   aks-default-34802672-vmss000002        <none>           <none>
scalar-kelpie-run-szmm8          1/1     Running     0          8m41s   10.42.40.110   aks-default-34802672-vmss000001        <none>           <none>
```

look at the logs

```console
$ kubetail scalar-kelpie-run
Will tail 3 logs...
scalar-kelpie-run-8m7rf
scalar-kelpie-run-fn76n
scalar-kelpie-run-szmm8
[scalar-kelpie-run-8m7rf] 2020-07-07 03:33:22,895 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 131.0 ops  Total success: 9643  Total failure: 19
[scalar-kelpie-run-8m7rf] 2020-07-07 03:33:23,895 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 128.0 ops  Total success: 9771  Total failure: 19
[scalar-kelpie-run-8m7rf] 2020-07-07 03:33:24,896 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 147.0 ops  Total success: 9918  Total failure: 19
[scalar-kelpie-run-8m7rf] 2020-07-07 03:33:25,896 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 145.0 ops  Total success: 10063  Total failure: 19
[scalar-kelpie-run-8m7rf] 2020-07-07 03:33:26,896 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 129.0 ops  Total success: 10192  Total failure: 19
[scalar-kelpie-run-8m7rf] 2020-07-07 03:33:27,897 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 144.0 ops  Total success: 10336  Total failure: 19
[scalar-kelpie-run-8m7rf] 2020-07-07 03:33:28,897 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 152.0 ops  Total success: 10488  Total failure: 22
[scalar-kelpie-run-8m7rf] 2020-07-07 03:33:29,897 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 128.0 ops  Total success: 10616  Total failure: 22
[scalar-kelpie-run-8m7rf] 2020-07-07 03:33:30,898 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 134.0 ops  Total success: 10750  Total failure: 23
[scalar-kelpie-run-8m7rf] 2020-07-07 03:33:31,898 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 142.0 ops  Total success: 10892  Total failure: 23
[scalar-kelpie-run-8m7rf] 2020-07-07 03:33:32,899 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 126.0 ops  Total success: 11018  Total failure: 25
[scalar-kelpie-run-szmm8] 2020-07-07 03:33:23,680 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 138.0 ops  Total success: 1850  Total failure: 2
[scalar-kelpie-run-fn76n] 2020-07-07 03:33:23,805 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 132.0 ops  Total success: 1822  Total failure: 5
[scalar-kelpie-run-szmm8] 2020-07-07 03:33:24,680 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 145.0 ops  Total success: 1995  Total failure: 2
[scalar-kelpie-run-szmm8] 2020-07-07 03:33:25,681 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 134.0 ops  Total success: 2129  Total failure: 2
[scalar-kelpie-run-fn76n] 2020-07-07 03:33:24,805 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 139.0 ops  Total success: 1961  Total failure: 6
[scalar-kelpie-run-szmm8] 2020-07-07 03:33:26,681 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 147.0 ops  Total success: 2276  Total failure: 2
```

end test

```console
$ kubectl get po
NAME                             READY   STATUS      RESTARTS   AGE
scalar-envoy-7dc48c76bb-26ndc    1/1     Running     0          41m
scalar-envoy-7dc48c76bb-jx5nx    1/1     Running     0          41m
scalar-envoy-7dc48c76bb-qsr9b    1/1     Running     0          41m
scalar-kelpie-5ztph              0/1     Completed   0          35m
scalar-kelpie-run-8m7rf          0/1     Completed   0          20m
scalar-kelpie-run-fn76n          0/1     Completed   0          20m
scalar-kelpie-run-szmm8          0/1     Completed   0          20m
scalar-ledger-6db6689f86-2fqfk   1/1     Running     0          41m
scalar-ledger-6db6689f86-4pccj   1/1     Running     0          41m
scalar-ledger-6db6689f86-9nvjn   1/1     Running     0          41m
scalardl-schema-5jd5v            0/1     Completed   0          42m
```

fetch result of each pod:

```console
$ kubectl logs --tail=15 scalar-kelpie-run-8m7rf
2020-07-07 03:42:39,085 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 61.0 ops  Total success: 93583  Total failure: 410
2020-07-07 03:42:40,085 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 97.0 ops  Total success: 93680  Total failure: 410
2020-07-07 03:42:41,086 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 61.9 ops  Total success: 93742  Total failure: 410
2020-07-07 03:42:41,099 [INFO  client.transfer.TransferReporter] ==== Statistics Summary ====
Throughput: 156.0 ops
Succeeded operations: 93742
Failed operations: 410
Mean latency: 383.0 ms
SD of latency: 173.0 ms
Max latency: 1815 ms
Latency at 50 percentile: 356 ms
Latency at 90 percentile: 596 ms
Latency at 99 percentile: 971 ms
2020-07-07 03:42:41,099 [INFO  com.scalar.kelpie.Kelpie] The job has been completed successfully
$ kubectl logs --tail=15 scalar-kelpie-run-fn76n
2020-07-07 03:43:09,047 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 213.0 ops  Total success: 91144  Total failure: 432
2020-07-07 03:43:10,048 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 224.0 ops  Total success: 91368  Total failure: 433
2020-07-07 03:43:11,048 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 150.0 ops  Total success: 91518  Total failure: 434
2020-07-07 03:43:11,068 [INFO  client.transfer.TransferReporter] ==== Statistics Summary ====
Throughput: 153.0 ops
Succeeded operations: 91518
Failed operations: 434
Mean latency: 392.0 ms
SD of latency: 166.0 ms
Max latency: 1706 ms
Latency at 50 percentile: 363 ms
Latency at 90 percentile: 597 ms
Latency at 99 percentile: 967 ms
2020-07-07 03:43:11,069 [INFO  com.scalar.kelpie.Kelpie] The job has been completed successfully
$ kubectl logs --tail=15 scalar-kelpie-run-szmm8
2020-07-07 03:43:08,875 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 220.0 ops  Total success: 91686  Total failure: 394
2020-07-07 03:43:09,875 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 219.0 ops  Total success: 91905  Total failure: 395
2020-07-07 03:43:10,876 [INFO  com.scalar.kelpie.stats.Stats] Throughput: 131.0 ops  Total success: 92036  Total failure: 395
2020-07-07 03:43:10,887 [INFO  client.transfer.TransferReporter] ==== Statistics Summary ====
Throughput: 153.0 ops
Succeeded operations: 92036
Failed operations: 395
Mean latency: 390.0 ms
SD of latency: 165.0 ms
Max latency: 1620 ms
Latency at 50 percentile: 361 ms
Latency at 90 percentile: 596 ms
Latency at 99 percentile: 958 ms
2020-07-07 03:43:10,887 [INFO  com.scalar.kelpie.Kelpie] The job has been completed successfully
```
