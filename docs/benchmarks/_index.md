---
title: Benchmarking Kafka
weight: 900
---

How to setup the environment for the Kafka Performance Test using Amazon PKE, GKE, EKS.

We are going to use [Banzai Cloud CLI](https://github.com/banzaicloud/banzai-cli) to create the cluster:

```bash
brew install banzaicloud/tap/banzai-cli
banzai login
```

## PKE

1. Create your own VPC and subnets on Amazon Management Console.

    1. Use the provided wizard and select VPC with Single Public Subnet. (Please remember the Availability Zone you chose.)
    1. Save the used route table id on the generated subnet
    1. Create two additional subnet in the VPC (choose different Availability Zones)

        - Modify your newly created subnet Auto Assign IP setting
        - Enable auto-assign public IPV4 address

    1. Assign the saved route table id to the two additional subnets

        - On Route Table page click Actions and Edit subnet associations

1. Create the cluster itself.

    ```bash
    banzai cluster create
    ```

    The required cluster template file can be found [here](https://raw.githubusercontent.com/banzaicloud/kafka-operator/master/docs/benchmarks/infrastructure/cluster_pke.json)

    > Please don't forget to fill out the template with the created ids.

    This will create a cluster with 3 nodes for ZK 3 for Kafka 1 Master node and 2 node for clients.
1. Create a StorageClass which enables high performance disk requests.

    ```bash
    kubectl create -f - <<EOF
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: fast-ssd
    provisioner: kubernetes.io/aws-ebs
    parameters:
      type: io1
      iopsPerGB: "50"
      fsType: ext4
    volumeBindingMode: WaitForFirstConsumer
    EOF
    ```

## GKE

1. Create the cluster itself:

    ```bash
    banzai cluster create
    ```

    The required cluster template file can be found [here](https://raw.githubusercontent.com/banzaicloud/kafka-operator/master/docs/benchmarks/infrastructure/cluster_gke.json)

    > Please don't forget to fill out the template with the created ids.

1. Create a StorageClass which enables high performance disk requests.

    ```bash
    kubectl create -f - <<EOF
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: fast-ssd
    provisioner: kubernetes.io/gce-pd
    parameters:
      type: pd-ssd
    volumeBindingMode: WaitForFirstConsumer
    EOF
    ```

## EKS

1. Create the cluster itself:

    ```bash
    banzai cluster create
    ```

    The required cluster template file can be found [here](https://raw.githubusercontent.com/banzaicloud/kafka-operator/master/docs/benchmarks/infrastructure/cluster_eks.json)

    > Please don't forget to fill out the template with the created ids.

    Once your cluster is up and running we can move on to set up the Kubernetes infrastructure.

1. Create a StorageClass which enables high performance disk requests.

    ```bash
    kubectl create -f - <<EOF
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: fast-ssd
    provisioner: kubernetes.io/aws-ebs
    parameters:
      type: io1
      iopsPerGB: "50"
      fsType: ext4
    volumeBindingMode: WaitForFirstConsumer
    EOF
    ```

## Install other required components

1. Create a Zookeeper cluster with 3 replicas using Pravega's Zookeeper Operator.

    ```bash
    helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com/
    helm install --name zookeeper-operator --namespace zookeeper banzaicloud-stable/zookeeper-operator
    kubectl create -f - <<EOF
    apiVersion: zookeeper.pravega.io/v1beta1
    kind: ZookeeperCluster
    metadata:
      name: example-zookeepercluster
      namespace: zookeeper
    spec:
      replicas: 1
    EOF
    ```

1. Install the latest version of Banzai Cloud Kafka Operator.

    ```bash
    helm install --name=kafka-operator banzaicloud-stable/kafka-operator
    ```

1. Create a 3 broker Kafka Cluster using the [provided](https://raw.githubusercontent.com/banzaicloud/kafka-operator/master/docs/benchmarks/infrastructure/kafka.yaml) yaml.

    This will install 3 brokers partitioned to three different zone with fast ssd.
1. Create a client container inside the cluster

    ```bash
    kubectl create -f - <<EOF
    apiVersion: v1
    kind: Pod
    metadata:
      annotations:
        linkerd.io/inject: enabled
      name: kafka-test
    spec:
      containers:
      - name: kafka-test
        image: "wurstmeister/kafka:2.12-2.1.1"
        # Just spin & wait forever
        command: [ "/bin/bash", "-c", "--" ]
        args: [ "while true; do sleep 3000; done;" ]
    EOF
    ```

1. Exec into this client and create the `perftest, perftest2, perftes3` topics.

    ```bash
    kubectl exec -it kafka-test bash
    ./opt/kafka/bin/kafka-topics.sh --zookeeper zookeeper-client.zookeeper:2181 --topic perftest --create --replication-factor 3 --partitions 3
    ./opt/kafka/bin/kafka-topics.sh --zookeeper zookeeper-client.zookeeper:2181 --topic perftest2 --create --replication-factor 3 --partitions 3
    ./opt/kafka/bin/kafka-topics.sh --zookeeper zookeeper-client.zookeeper:2181 --topic perftest3 --create --replication-factor 3 --partitions 3
    ```

Monitoring environment automatically installed, find your cluster and Grafanas UI/credentials on our [UI](https://banzaicloud.com/pipeline/). To monitor the infrastructure we used the official Node Exporter dashboard available with id `1860`.

## Run the tests

1. Run perf test against the cluster, by building the provided Docker [image](https://raw.githubusercontent.com/banzaicloud/kafka-operator/master/docs/benchmarks/loadgens/Dockerfile)

    ```bash
    docker build -t yourname/perfload:0.1.0 /loadgens
    docker push yourname/perfload:0.1.0
    ```

1. Submit the perf test application:

```yaml
kubectl create -f - <<EOF
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    app: loadtest
  annotations:
    linkerd.io/inject: enabled
  name: perf-load
  namespace: default
spec:
  progressDeadlineSeconds: 600
  replicas: 4
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: loadtest
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: loadtest
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: nodepool.banzaicloud.io/name
                operator: In
                values:
                - pool3
      containers:
      - args:
        - -brokers=kafka-0:29092,kafka-1:29092,kafka-2:29092
        - -topic=perftest
        - -required-acks=all
        - -message-size=512
        - -workers=20
        image: yourorg/yourimage:yourtag
        imagePullPolicy: Always
        name: sangrenel
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
---

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    app: loadtest
  name: perf-load
  namespace: default
spec:
  progressDeadlineSeconds: 600
  replicas: 4
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: loadtest
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: loadtest
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: nodepool.banzaicloud.io/name
                operator: In
                values:
                - clients
      containers:
      - args:
        - -brokers=kafka-0,kafka-1,kafka-2:29092
        - -topic=perftest2
        - -required-acks=all
        - -message-size=512
        - -workers=20
        image: yourorg/yourimage:yourtag
        imagePullPolicy: Always
        name: sangrenel
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
---

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    app: loadtest
  name: perf-load
  namespace: default
spec:
  progressDeadlineSeconds: 600
  replicas: 4
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: loadtest
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: loadtest
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: nodepool.banzaicloud.io/name
                operator: In
                values:
                - clients
      containers:
      - args:
        - -brokers=kafka-0,kafka-1,kafka-2:29092
        - -topic=perftest
        - -required-acks=all
        - -message-size=512
        - -workers=20
        image: yourorg/yourimage:yourtag
        imagePullPolicy: Always
        name: sangrenel
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
EOF
```
