---
title: Kafka operator
img: /docs/supertubes/kafka-operator/img/kafka-operator-arch.png
weight: 700
cascade:
  module: kafka-operator
  githubEditUrl: "https://github.com/banzaicloud/kafka-operator-docs/edit/master/docs/"
---

The Banzai Cloud Kafka operator is a Kubernetes operator to automate provisioning, management, autoscaling and operations of [Apache Kafka](https://kafka.apache.org) clusters deployed to K8s.

## Overview

[Apache Kafka](https://kafka.apache.org) is an open-source distributed streaming platform, and some of the main features of the **Kafka-operator** are:

- the provisioning of secure and production-ready Kafka clusters
- **fine grained** broker configuration support
- advanced and highly configurable External Access via LoadBalancers using **Envoy**
- graceful Kafka cluster **scaling and rebalancing**
- monitoring via **Prometheus**
- encrypted communication using SSL
- automatic reaction and self healing based on alerts (plugin system, with meaningful default alert plugins) using **Cruise Control**
- graceful rolling upgrade
- advanced topic and user management via CRD

![Kafka-operator architecture](./img/kafka-operator-arch.png)

>We took a different approach to what's out there - we believe for a good reason - please read on to understand more about our [design motivations](features/) and some of the [scenarios](scenarios/) which were driving us to create the Banzai Cloud Kafka operator.

{{% include-headless "doc/kafka-operator-supertubes-intro.md" %}}

## Motivation

At [Banzai Cloud](https://banzaicloud.com) we are building a Kubernetes distribution, [PKE](/products/pke/), and a hybrid-cloud container management platform, [Pipeline](/products/pipeline/), that operate Kafka clusters (among other types) for our customers. Apache Kafka predates Kubernetes and was designed mostly for `static` on-premise environments. State management, node identity, failover, etc all come part and parcel with Kafka, so making it work properly on Kubernetes and on an underlying dynamic environment can be a challenge.

There are already several approaches to operating Kafka on Kubernetes, however, we did not find them appropriate for use in a highly dynamic environment, nor capable of meeting our customers' needs. At the same time, there is substantial interest within the Kafka community for a solution which enables Kafka on Kubernetes, both in the open source and closed source space.

- [Helm chart](https://github.com/confluentinc/cp-helm-charts/tree/master/charts/cp-kafka)
- [Yaml files](https://github.com/Yolean/kubernetes-kafka)
- [Strimzi Kafka Operator](https://github.com/strimzi/strimzi-kafka-operator)
- Confluent operator

Join us as we take a deep dive into some of the details of the most popular pre-existing solutions, as well as our own:

|               | Banzai Cloud | Krallistic | Strimzi | Confluent|
| ------------- | ------------ | ------------ | ------------ | ------------ |
| Open source  | Apache 2 | Apache 2|Apache 2| No|
| Fine grained broker config support  | Yes (learn more) | Limited via StatefulSet|Limited via StatefulSet|Limited via StatefulSet|
| Fine grained broker volume support  | Yes (learn more) | Limited via StatefulSet|Limited via StatefulSet|Limited via StatefulSet|
| Monitoring  | Yes | Yes|Yes|Yes|
| Encryption using SSL  | Yes | Yes|Yes|Yes|
| Rolling Update  | Yes | No |Yes|Yes|
| Cluster external accesses  | Envoy (single LB) | Nodeport |Nodeport or LB/broker|Yes (N/A)|
| User Management via CRD  | Yes | No |Yes|No|
| Topic management via CRD  | Yes | No |Yes|No|
| Reacting to Alerts| Yes (Prometheus + Cruise Control | No |No|No|
| Graceful Cluster Scaling (up and down)| Yes (using Cruise Control) | No |Yes(using Cruise Control)|Yes|

*-if you find any of this information inaccurate, [contact us and we'll fix it](/contact/)*

>We took a different approach to what's out there - we believe for a good reason - please read on to understand more about our [design motivations](features/) and some of the [scenarios](scenarios/) which were driving us to create the Banzai Cloud Kafka operator.

Finally, our motivation is to build an open source solution and a community which drives the innovation and features of this operator. We are long term contributors and active community members of both Apache Kafka and Kubernetes, and we hope to recreate a similar community around this operator.

If you are willing to kickstart your managed Apache Kafka experience on 5 cloud providers, on-premise or hybrid environments, check out the free developer beta of the [Banzai Cloud Pipeline platform](/products/pipeline/):
