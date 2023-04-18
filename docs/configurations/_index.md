---
title: Configure Kafka cluster
shorttitle: Configure
aliases:
  - /sdm/koperator/configurations/kafkacluster
weight: 250
---

Koperator provides convenient ways of configuring Kafka resources through [Kubernetes custom resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/).

List of our custom resources:

- [KafkaCluster templates]({{< relref "kafkacluster-cr-templates/_index.md" >}})
- [KafkaTopic]({{< relref "../topics.md" >}})
- KafkaUser

## Overview

The **KafkaCluster** custom resource is the main configuration resource for the Kafka clusters.  
It defines the Apache Kafka cluster properties, like Kafka brokers and listeners configurations.
By deploying the KafkaCluster custom resource, Koperator sets up your Kafka cluster.  
You can change your Kafka cluster properties by updating the KafkaCluster custom resource.
The **KafkaCluster** custom resource always reflects to your Kafka cluster: when something has changed in your KafkaCluster custom resource, Koperator reconciles the changes to your Kafka cluster.

## Schema reference {#schema-ref}

The schema reference for the **KafkaCluster** custom resource is available [here](https://docs.calisti.app/sdm/koperator/reference/crd/kafkaclusters.kafka.banzaicloud.io/).


