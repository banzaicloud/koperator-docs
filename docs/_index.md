---
title: Koperator
img: /docs/koperator-docs/img/kafka-operator-arch.png
weight: 700
aliases:
  - /sdm/koperator/features/
cascade:
  module: kafka-operator
  githubEditUrl: "https://github.com/banzaicloud/koperator-docs/edit/master/docs/"
  operatorName: "Koperator"
---

The {{< kafka-operator >}} (formerly called Banzai Cloud Kafka Operator) is a Kubernetes operator to automate provisioning, management, autoscaling and operations of [Apache Kafka](https://kafka.apache.org) clusters deployed to K8s.

## Overview

[Apache Kafka](https://kafka.apache.org) is an open-source distributed streaming platform, and some of the main features of the **{{< kafka-operator >}}** are:

- the provisioning of secure and production-ready Kafka clusters
- **fine grained** broker configuration support
- advanced and highly configurable External Access via LoadBalancers using **Envoy**
- graceful Kafka cluster **scaling and rebalancing**
- monitoring via **Prometheus**
- encrypted communication using SSL
- automatic reaction and self healing based on alerts (plugin system, with meaningful default alert plugins) using **Cruise Control**
- graceful rolling upgrade
- advanced topic and user management via CRD

![{{< kafka-operator >}} architecture](/sdm/koperator/img/kafka-operator-arch.png)

{{% include-headless "kafka-operator-supertubes-intro.md" "sdm" %}}

## Motivation

Apache Kafka predates Kubernetes and was designed mostly for `static` on-premises environments. State management, node identity, failover, etc all come part and parcel with Kafka, so making it work properly on Kubernetes and on an underlying dynamic environment can be a challenge.

There are already several approaches to operating Apache Kafka on Kubernetes, however, we did not find them appropriate for use in a highly dynamic environment, nor capable of meeting our customers' needs. At the same time, there is substantial interest within the Kafka community for a solution which enables Kafka on Kubernetes, both in the open source and closed source space.
>We took a different approach to what's out there - we believe for a good reason - please read on to understand more about our [design motivations](#features) and some of the [scenarios](scenarios/) which were driving us to create the {{< kafka-operator >}}.

Finally, our motivation is to build an open source solution and a community which drives the innovation and features of this operator. We are long-term contributors and active community members of both Apache Kafka and Kubernetes, and we hope to recreate a similar community around this operator.

## Koperator features {#features}

### Design motivations
Kafka is a stateful application. The first piece of the puzzle is the Broker, which is a simple server capable of creating/forming a cluster with other Brokers. Every Broker has his own **unique** configuration which differs slightly from all others - the most relevant of which is the ***unique broker ID***.

All Kafka on Kubernetes operators use [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) to create a Kafka Cluster. Just to quickly recap from the K8s docs:

>StatefulSet manages the deployment and scaling of a set of Pods, and provide guarantees about their ordering and uniqueness. Like a Deployment, a StatefulSet manages Pods that are based on an identical container spec. Unlike a Deployment, a StatefulSet maintains sticky identities for each of its Pods. These pods are created from the same spec, but are not interchangeable: each has a persistent identifier that is maintained across any rescheduling.

How does this look from the perspective of Apache Kafka?

With StatefulSet we get:

- unique Broker IDs generated during Pod startup
- networking between brokers with headless services
- unique Persistent Volumes for Brokers

Using StatefulSet we **lose:**

- the ability to modify the configuration of unique Brokers
- to remove a specific Broker from a cluster (StatefulSet always removes the most recently created Broker)
- to use multiple, different Persistent Volumes for each Broker

{{< kafka-operator >}} uses `simple` Pods, ConfigMaps, and PersistentVolumeClaims, instead of StatefulSet. Using these resources allows us to build an Operator which is better suited to manage Apache Kafka.

With the {{< kafka-operator >}} you can:

- modify the configuration of unique Brokers
- remove specific Brokers from clusters
- use multiple Persistent Volumes for each Broker

## Features 

### Fine Grained Broker Configuration Support

We needed to be able to react to events in a fine-grained way for each Broker - and not in the limited way StatefulSet does (which, for example, removes the most recently created Brokers). Some of the available solutions try to overcome these deficits by placing scripts inside the container to generate configurations at runtime, whereas the {{< kafka-operator >}}'s configurations are deterministically placed in specific Configmaps.

### Graceful Kafka Cluster Scaling with the help of our CruiseControlOperation custom resource

We know how to operate Apache Kafka at scale (we are contributors and have been operating Kafka on Kubernetes for years now). We believe, however, that LinkedIn has even more experience than we do. To scale Kafka clusters both up and down gracefully, we integrated LinkedIn's [Cruise-Control](https://github.com/linkedin/cruise-control) to do the hard work for us. We already have good defaults (i.e. plugins) that react to events, but we also allow our users to write their own.

### External Access via LoadBalancer

The {{< kafka-operator >}} externalizes access to Apache Kafka using a dynamically (re)configured Envoy proxy. Using Envoy allows us to use **a single** LoadBalancer, so there's no need for a LoadBalancer for each Broker.

![Kafka External Access](/sdm/koperator/img/kafka-external.png)

### Communication via SSL

The operator fully automates Kafka's SSL support.
The operator can provision the required secrets and certificates for you, or you can provide your own.

![SSL support for Kafka](/sdm/koperator/img/kafka-ssl.png)

### Monitoring via Prometheus

The {{< kafka-operator >}} exposes Cruise-Control and Kafka JMX metrics to Prometheus.

### Reacting on Alerts

{{< kafka-operator >}} acts as a **Prometheus Alert Manager**. It receives alerts defined in Prometheus, and creates actions based on Prometheus alert annotations.

Currently, there are three default actions (which can be extended):

- upscale cluster (add a new Broker)
- downscale cluster (remove a Broker)
- add additional disk to a Broker

### Graceful Rolling Upgrade

Operator supports graceful rolling upgrade, It means the operator will check if the cluster is healthy.
It basically checks if the cluster has offline partitions, and all the replicas are in sync.
It proceeds only when the failure threshold is smaller than the configured one.

The operator also allows to create special alerts on Prometheus, which affects the rolling upgrade state, by
increasing the error rate.

### Dynamic Configuration Support

Kafka operates with three type of configurations:

- Read-only
- ClusterWide
- PerBroker

Read-only config requires broker restart to update all the others may be updated dynamically.
Operator CRD distinguishes these fields, and proceed with the right action. It can be a rolling upgrade, or
a dynamic reconfiguration.

### Seamless Istio mesh support

- Operator allows to use ClusterIP services instead of Headless, which still works better in case of Service meshes.
- To avoid too early Kafka initialization, which might lead to unready sidecar container. The operator uses a small script to mitigate this behaviour. Any Kafka image can be used with the only requirement of an available **curl** command.
- To access a Kafka cluster which runs inside the mesh. Operator supports creating Istio ingress gateways.


---
Apache Kafka, Kafka, and the Kafka logo are either registered trademarks or trademarks of The Apache Software Foundation in the United States and other countries.
