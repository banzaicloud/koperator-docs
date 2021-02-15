---
title: Kafka operator troubleshooting
shorttitle: Troubleshooting
weight: 400
---

The following tips and commands can help you to troubleshoot your Kafka operator installation.

## First things to do

1. Check that the necessary CRDs are installed. Issue the following command: `kubectl get crd`
   The output should include the following CRDs. Note that some CRDs might be missing from your output depending on the components you have installed:

    ```bash
    alertmanagerconfigs.monitoring.coreos.com    2021-02-15T09:42:06Z
    alertmanagers.monitoring.coreos.com          2021-02-15T09:42:06Z
    certificaterequests.cert-manager.io          2021-02-15T09:39:38Z
    certificates.cert-manager.io                 2021-02-15T09:39:38Z
    challenges.acme.cert-manager.io              2021-02-15T09:39:39Z
    clusterissuers.cert-manager.io               2021-02-15T09:39:40Z
    issuers.cert-manager.io                      2021-02-15T09:39:40Z
    kafkaclusters.kafka.banzaicloud.io           2021-02-15T09:44:48Z
    kafkatopics.kafka.banzaicloud.io             2021-02-15T09:44:48Z
    kafkausers.kafka.banzaicloud.io              2021-02-15T09:44:49Z
    orders.acme.cert-manager.io                  2021-02-15T09:39:41Z
    podmonitors.monitoring.coreos.com            2021-02-15T09:42:07Z
    probes.monitoring.coreos.com                 2021-02-15T09:42:07Z
    prometheuses.monitoring.coreos.com           2021-02-15T09:42:07Z
    prometheusrules.monitoring.coreos.com        2021-02-15T09:42:09Z
    servicemonitors.monitoring.coreos.com        2021-02-15T09:42:09Z
    thanosrulers.monitoring.coreos.com           2021-02-15T09:42:10Z
    zookeeperclusters.zookeeper.pravega.io       2021-02-15T09:40:15Z
    ```

1. Verify that the Kafka operator pod is running. Issue the following command: `kubectl get pods -n kafka|grep kafka-operator`
    The output should include a running pod, for example:

    ```bash
    NAME                                          READY   STATUS      RESTARTS   AGE
    kafka-operator-operator-6968c67c7b-9d2xq   2/2     Running   0          10m
    ```

1. Verify that the Kafka broker pods are running. Issue the following command: `kubectl get pods -n kafka`
    The output should include a numbered running pod for each broker, with names like *kafka-0-zcxk7*, *kafka-1-2nhj5*, and so on, for example:

    ```bash
    NAME                                       READY   STATUS    RESTARTS   AGE
    kafka-0-zcxk7                              1/1     Running   0          3h16m
    kafka-1-2nhj5                              1/1     Running   0          3h15m
    kafka-2-z4t84                              1/1     Running   0          3h15m
    kafka-cruisecontrol-7f77ccf997-cqhsw       1/1     Running   1          3h15m
    kafka-operator-operator-6968c67c7b-9d2xq   2/2     Running   0          3h17m
    prometheus-kafka-prometheus-0              2/2     Running   1          3h16m
    ```

1. If you see any problems, check the logs of the affected pod, for example:

    ```bash
    kubectl logs kafka-0-zcxk7 -n kafka
    ```

1. Check the status (State) of your resources. For example:

    ```bash
    kubectl get KafkaCluster kafka -n kafka -o jsonpath="{.status}" |jq
    ```

1. Check the status of your Zookeeper deployment, and the logs of the zookeeper-operator and zookeeper pods.

    ```bash
    kubectl get pods -n zookeeper
    ```

{{< toc >}}

## Check the KafkaCluster configuration

You can display the current configuration of your Kafka cluster using the following command:
`kubectl describe KafkaCluster kafka -n kafka`

The output looks like the following:

```yaml
Name:         kafka
Namespace:    kafka
Labels:       controller-tools.k8s.io=1.0
Annotations:  <none>
API Version:  kafka.banzaicloud.io/v1beta1
Kind:         KafkaCluster
Metadata:
  Creation Timestamp:  2021-02-15T09:46:02Z
  Finalizers:
    finalizer.kafkaclusters.kafka.banzaicloud.io
    topics.kafkaclusters.kafka.banzaicloud.io
    users.kafkaclusters.kafka.banzaicloud.io
  Generation:  2
  Managed Fields:
    API Version:  kafka.banzaicloud.io/v1beta1
    Fields Type:  FieldsV1
    fieldsV1:
      f:metadata:
        f:labels:
          .:
          f:controller-tools.k8s.io:
      f:spec:
        .:
        f:brokerConfigGroups:
          .:
          f:default:
            .:
            f:brokerAnnotations:
              .:
              f:prometheus.io/port:
              f:prometheus.io/scrape:
            f:storageConfigs:
        f:brokers:
        f:clusterImage:
        f:cruiseControlConfig:
          .:
          f:clusterConfig:
          f:config:
          f:cruiseControlTaskSpec:
            .:
            f:RetryDurationMinutes:
          f:topicConfig:
            .:
            f:partitions:
            f:replicationFactor:
        f:headlessServiceEnabled:
        f:listenersConfig:
          .:
          f:internalListeners:
        f:oneBrokerPerNode:
        f:readOnlyConfig:
        f:rollingUpgradeConfig:
          .:
          f:failureThreshold:
        f:zkAddresses:
    Manager:      kubectl-create
    Operation:    Update
    Time:         2021-02-15T09:46:02Z
    API Version:  kafka.banzaicloud.io/v1beta1
    Fields Type:  FieldsV1
    fieldsV1:
      f:metadata:
        f:finalizers:
      f:spec:
        f:disruptionBudget:
        f:envoyConfig:
        f:istioIngressConfig:
        f:monitoringConfig:
          .:
          f:jmxImage:
          f:pathToJar:
        f:vaultConfig:
          .:
          f:authRole:
          f:issuePath:
          f:pkiPath:
          f:userStore:
      f:status:
        .:
        f:alertCount:
        f:brokersState:
          .:
          f:0:
            .:
            f:configurationState:
            f:gracefulActionState:
              .:
              f:cruiseControlState:
              f:errorMessage:
            f:rackAwarenessState:
          f:1:
            .:
            f:configurationState:
            f:gracefulActionState:
              .:
              f:cruiseControlState:
              f:errorMessage:
            f:rackAwarenessState:
          f:2:
            .:
            f:configurationState:
            f:gracefulActionState:
              .:
              f:cruiseControlState:
              f:errorMessage:
            f:rackAwarenessState:
        f:cruiseControlTopicStatus:
        f:rollingUpgradeStatus:
          .:
          f:errorCount:
          f:lastSuccess:
        f:state:
    Manager:         manager
    Operation:       Update
    Time:            2021-02-15T09:47:23Z
  Resource Version:  18406
  Self Link:         /apis/kafka.banzaicloud.io/v1beta1/namespaces/kafka/kafkaclusters/kafka
  UID:               daaf7df9-78d8-4718-8784-2aa96dff3329
Spec:
  Broker Config Groups:
    Default:
      Broker Annotations:
        prometheus.io/port:    9020
        prometheus.io/scrape:  true
      Storage Configs:
        Mount Path:  /kafka-logs
        Pvc Spec:
          Access Modes:
            ReadWriteOnce
          Resources:
            Requests:
              Storage:  10Gi
  Brokers:
    Broker Config Group:  default
    Id:                   0
    Broker Config Group:  default
    Id:                   1
    Broker Config Group:  default
    Id:                   2
  Cluster Image:          ghcr.io/banzaicloud/kafka:2.13-2.6.0-bzc.1
  Cruise Control Config:
    Cluster Config:  {
  "min.insync.replicas": 3
}

    Config:  # Copyright 2017 LinkedIn Corp. Licensed under the BSD 2-Clause License (the "License"). See License in the project root for license information.
#
# This is an example property file for Kafka Cruise Control. See KafkaCruiseControlConfig for more details.
# Configuration for the metadata client.
# =======================================
# The maximum interval in milliseconds between two metadata refreshes.
#metadata.max.age.ms=300000
# Client id for the Cruise Control. It is used for the metadata client.
#client.id=kafka-cruise-control
# The size of TCP send buffer bytes for the metadata client.
#send.buffer.bytes=131072
# The size of TCP receive buffer size for the metadata client.
#receive.buffer.bytes=131072
# The time to wait before disconnect an idle TCP connection.
#connections.max.idle.ms=540000
# The time to wait before reconnect to a given host.
#reconnect.backoff.ms=50
# The time to wait for a response from a host after sending a request.
#request.timeout.ms=30000
# Configurations for the load monitor
# =======================================
# The number of metric fetcher thread to fetch metrics for the Kafka cluster
num.metric.fetchers=1
# The metric sampler class
metric.sampler.class=com.linkedin.kafka.cruisecontrol.monitor.sampling.CruiseControlMetricsReporterSampler
# Configurations for CruiseControlMetricsReporterSampler
metric.reporter.topic.pattern=__CruiseControlMetrics
# The sample store class name
sample.store.class=com.linkedin.kafka.cruisecontrol.monitor.sampling.KafkaSampleStore
# The config for the Kafka sample store to save the partition metric samples
partition.metric.sample.store.topic=__KafkaCruiseControlPartitionMetricSamples
# The config for the Kafka sample store to save the model training samples
broker.metric.sample.store.topic=__KafkaCruiseControlModelTrainingSamples
# The replication factor of Kafka metric sample store topic
sample.store.topic.replication.factor=2
# The config for the number of Kafka sample store consumer threads
num.sample.loading.threads=8
# The partition assignor class for the metric samplers
metric.sampler.partition.assignor.class=com.linkedin.kafka.cruisecontrol.monitor.sampling.DefaultMetricSamplerPartitionAssignor
# The metric sampling interval in milliseconds
metric.sampling.interval.ms=120000
metric.anomaly.detection.interval.ms=180000
# The partition metrics window size in milliseconds
partition.metrics.window.ms=300000
# The number of partition metric windows to keep in memory
num.partition.metrics.windows=1
# The minimum partition metric samples required for a partition in each window
min.samples.per.partition.metrics.window=1
# The broker metrics window size in milliseconds
broker.metrics.window.ms=300000
# The number of broker metric windows to keep in memory
num.broker.metrics.windows=20
# The minimum broker metric samples required for a partition in each window
min.samples.per.broker.metrics.window=1
# The configuration for the BrokerCapacityConfigFileResolver (supports JBOD and non-JBOD broker capacities)
capacity.config.file=config/capacity.json
#capacity.config.file=config/capacityJBOD.json
# Configurations for the analyzer
# =======================================
# The list of goals to optimize the Kafka cluster for with pre-computed proposals
default.goals=com.linkedin.kafka.cruisecontrol.analyzer.goals.ReplicaCapacityGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.DiskCapacityGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkInboundCapacityGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkOutboundCapacityGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.CpuCapacityGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.ReplicaDistributionGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.PotentialNwOutGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.DiskUsageDistributionGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkInboundUsageDistributionGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkOutboundUsageDistributionGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.CpuUsageDistributionGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.TopicReplicaDistributionGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.LeaderBytesInDistributionGoal
# The list of supported goals
goals=com.linkedin.kafka.cruisecontrol.analyzer.goals.ReplicaCapacityGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.DiskCapacityGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkInboundCapacityGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkOutboundCapacityGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.CpuCapacityGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.ReplicaDistributionGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.PotentialNwOutGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.DiskUsageDistributionGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkInboundUsageDistributionGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkOutboundUsageDistributionGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.CpuUsageDistributionGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.TopicReplicaDistributionGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.LeaderBytesInDistributionGoal,com.linkedin.kafka.cruisecontrol.analyzer.kafkaassigner.KafkaAssignerDiskUsageDistributionGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.PreferredLeaderElectionGoal
# The list of supported hard goals
hard.goals=com.linkedin.kafka.cruisecontrol.analyzer.goals.ReplicaCapacityGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.DiskCapacityGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkInboundCapacityGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkOutboundCapacityGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.CpuCapacityGoal
# The minimum percentage of well monitored partitions out of all the partitions
min.monitored.partition.percentage=0.95
# The balance threshold for CPU
cpu.balance.threshold=1.1
# The balance threshold for disk
disk.balance.threshold=1.1
# The balance threshold for network inbound utilization
network.inbound.balance.threshold=1.1
# The balance threshold for network outbound utilization
network.outbound.balance.threshold=1.1
# The balance threshold for the replica count
replica.count.balance.threshold=1.1
# The capacity threshold for CPU in percentage
cpu.capacity.threshold=0.8
# The capacity threshold for disk in percentage
disk.capacity.threshold=0.8
# The capacity threshold for network inbound utilization in percentage
network.inbound.capacity.threshold=0.8
# The capacity threshold for network outbound utilization in percentage
network.outbound.capacity.threshold=0.8
# The threshold to define the cluster to be in a low CPU utilization state
cpu.low.utilization.threshold=0.0
# The threshold to define the cluster to be in a low disk utilization state
disk.low.utilization.threshold=0.0
# The threshold to define the cluster to be in a low network inbound utilization state
network.inbound.low.utilization.threshold=0.0
# The threshold to define the cluster to be in a low disk utilization state
network.outbound.low.utilization.threshold=0.0
# The metric anomaly percentile upper threshold
metric.anomaly.percentile.upper.threshold=90.0
# The metric anomaly percentile lower threshold
metric.anomaly.percentile.lower.threshold=10.0
# How often should the cached proposal be expired and recalculated if necessary
proposal.expiration.ms=60000
# The maximum number of replicas that can reside on a broker at any given time.
max.replicas.per.broker=10000
# The number of threads to use for proposal candidate precomputing.
num.proposal.precompute.threads=1
# the topics that should be excluded from the partition movement.
#topics.excluded.from.partition.movement
# Configurations for the executor
# =======================================
# The max number of partitions to move in/out on a given broker at a given time.
num.concurrent.partition.movements.per.broker=10
# The interval between two execution progress checks.
execution.progress.check.interval.ms=10000
# Configurations for anomaly detector
# =======================================
# The goal violation notifier class
anomaly.notifier.class=com.linkedin.kafka.cruisecontrol.detector.notifier.SelfHealingNotifier
# The metric anomaly finder class
metric.anomaly.finder.class=com.linkedin.kafka.cruisecontrol.detector.KafkaMetricAnomalyFinder
# The anomaly detection interval
anomaly.detection.interval.ms=10000
# The goal violation to detect.
anomaly.detection.goals=com.linkedin.kafka.cruisecontrol.analyzer.goals.ReplicaCapacityGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.DiskCapacityGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkInboundCapacityGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkOutboundCapacityGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.CpuCapacityGoal
# The interested metrics for metric anomaly analyzer.
metric.anomaly.analyzer.metrics=BROKER_PRODUCE_LOCAL_TIME_MS_MAX,BROKER_PRODUCE_LOCAL_TIME_MS_MEAN,BROKER_CONSUMER_FETCH_LOCAL_TIME_MS_MAX,BROKER_CONSUMER_FETCH_LOCAL_TIME_MS_MEAN,BROKER_FOLLOWER_FETCH_LOCAL_TIME_MS_MAX,BROKER_FOLLOWER_FETCH_LOCAL_TIME_MS_MEAN,BROKER_LOG_FLUSH_TIME_MS_MAX,BROKER_LOG_FLUSH_TIME_MS_MEAN
## Adjust accordingly if your metrics reporter is an older version and does not produce these metrics.
#metric.anomaly.analyzer.metrics=BROKER_PRODUCE_LOCAL_TIME_MS_50TH,BROKER_PRODUCE_LOCAL_TIME_MS_999TH,BROKER_CONSUMER_FETCH_LOCAL_TIME_MS_50TH,BROKER_CONSUMER_FETCH_LOCAL_TIME_MS_999TH,BROKER_FOLLOWER_FETCH_LOCAL_TIME_MS_50TH,BROKER_FOLLOWER_FETCH_LOCAL_TIME_MS_999TH,BROKER_LOG_FLUSH_TIME_MS_50TH,BROKER_LOG_FLUSH_TIME_MS_999TH
# The zk path to store failed broker information.
failed.brokers.zk.path=/CruiseControlBrokerList
# Topic config provider class
topic.config.provider.class=com.linkedin.kafka.cruisecontrol.config.KafkaTopicConfigProvider
# The cluster configurations for the KafkaTopicConfigProvider
cluster.configs.file=config/clusterConfigs.json
# The maximum time in milliseconds to store the response and access details of a completed user task.
completed.user.task.retention.time.ms=21600000
# The maximum time in milliseconds to retain the demotion history of brokers.
demotion.history.retention.time.ms=86400000
# The maximum number of completed user tasks for which the response and access details will be cached.
max.cached.completed.user.tasks=100
# The maximum number of user tasks for concurrently running in async endpoints across all users.
max.active.user.tasks=5
# Enable self healing for all anomaly detectors, unless the particular anomaly detector is explicitly disabled
self.healing.enabled=true
# Enable self healing for broker failure detector
#self.healing.broker.failure.enabled=true
# Enable self healing for goal violation detector
#self.healing.goal.violation.enabled=true
# Enable self healing for metric anomaly detector
#self.healing.metric.anomaly.enabled=true
# configurations for the webserver
# ================================
# HTTP listen port
webserver.http.port=9090
# HTTP listen address
webserver.http.address=0.0.0.0
# Whether CORS support is enabled for API or not
webserver.http.cors.enabled=false
# Value for Access-Control-Allow-Origin
webserver.http.cors.origin=http://localhost:8080/
# Value for Access-Control-Request-Method
webserver.http.cors.allowmethods=OPTIONS,GET,POST
# Headers that should be exposed to the Browser (Webapp)
# This is a special header that is used by the
# User Tasks subsystem and should be explicitly
# Enabled when CORS mode is used as part of the
# Admin Interface
webserver.http.cors.exposeheaders=User-Task-ID
# REST API default prefix
# (dont forget the ending *)
webserver.api.urlprefix=/kafkacruisecontrol/*
# Location where the Cruise Control frontend is deployed
webserver.ui.diskpath=./cruise-control-ui/dist/
# URL path prefix for UI
# (dont forget the ending *)
webserver.ui.urlprefix=/*
# Time After which request is converted to Async
webserver.request.maxBlockTimeMs=10000
# Default Session Expiry Period
webserver.session.maxExpiryTimeMs=60000
# Session cookie path
webserver.session.path=/
# Server Access Logs
webserver.accesslog.enabled=true
# Location of HTTP Request Logs
webserver.accesslog.path=access.log
# HTTP Request Log retention days
webserver.accesslog.retention.days=14

    Cruise Control Task Spec:
      Retry Duration Minutes:  5
    Topic Config:
      Partitions:          12
      Replication Factor:  3
  Disruption Budget:
  Envoy Config:
  Headless Service Enabled:  true
  Istio Ingress Config:
  Listeners Config:
    Internal Listeners:
      Container Port:                       29092
      Name:                                 internal
      Type:                                 plaintext
      Used For Inner Broker Communication:  true
      Container Port:                       29093
      Name:                                 controller
      Type:                                 plaintext
      Used For Controller Communication:    true
      Used For Inner Broker Communication:  false
  Monitoring Config:
    Jmx Image:          
    Path To Jar:        
  One Broker Per Node:  false
  Read Only Config:     auto.create.topics.enable=false
cruise.control.metrics.topic.auto.create=true
cruise.control.metrics.topic.num.partitions=1
cruise.control.metrics.topic.replication.factor=2

  Rolling Upgrade Config:
    Failure Threshold:  1
  Vault Config:
    Auth Role:   
    Issue Path:  
    Pki Path:    
    User Store:  
  Zk Addresses:
    zookeeper-client.zookeeper:2181
Status:
  Alert Count:  0
  Brokers State:
    0:
      Configuration State:  ConfigInSync
      Graceful Action State:
        Cruise Control State:  GracefulUpscaleSucceeded
        Error Message:         CruiseControl not yet ready
      Rack Awareness State:    
    1:
      Configuration State:  ConfigInSync
      Graceful Action State:
        Cruise Control State:  GracefulUpscaleSucceeded
        Error Message:         CruiseControl not yet ready
      Rack Awareness State:    
    2:
      Configuration State:  ConfigInSync
      Graceful Action State:
        Cruise Control State:   GracefulUpscaleSucceeded
        Error Message:          CruiseControl not yet ready
      Rack Awareness State:     
  Cruise Control Topic Status:  CruiseControlTopicReady
  Rolling Upgrade Status:
    Error Count:   0
    Last Success:  
  State:           ClusterRunning
Events:            <none>
```

## Getting Support

If you encounter any problems that the documentation does not address, [file an issue](https://github.com/banzaicloud/kafka-operator/issues) or talk to us on the Banzai Cloud Slack channel [#kafka-operator](https://slack.banzaicloud.io/).

[Commercial support]({{< relref "/docs/supertubes/kafka-operator/support/">}}) is also available for the Kafka operator.

Before asking for help, prepare the following information to make troubleshooting faster:

- Kafka operator version
- Kubernetes version (**kubectl version**)
- Helm/chart version (if you installed the Kafka operator with Helm)
- Kafka operator logs, for example **kubectl logs kafka-operator-operator-6968c67c7b-9d2xq manager -n kafka** and **kubectl logs kafka-operator-operator-6968c67c7b-9d2xq kube-rbac-proxy -n kafka**
- Kafka broker logs
- Kafka operator configuration
- Kafka cluster configuration (**kubectl describe KafkaCluster kafka -n kafka**)
- Zookeeper configuration (**kubectl describe ZookeeperCluster zookeeper -n zookeeper**)
- Zookeeper logs (**kubectl logs zookeeper-operator-5c9b597bcc-vkdz9 -n zookeeper**)
Do not forget to remove any sensitive information (for example, passwords and private keys) before sharing.