---
title: Kafka operator troubleshooting
shorttitle: Troubleshooting
weight: 400
---

The following tips and commands can help you to troubleshoot your Kafka operator installation.

## First things to do

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

    ...

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

[Commercial support]({{< relref "/docs/supertubes/kafka-operator/support.md">}}) is also available for the Kafka operator.

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