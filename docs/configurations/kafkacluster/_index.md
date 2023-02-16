---
title: Kafka cluster configuration
shorttitle: KafkaCluster
weight: 7000
---

## Overview

The **KafkaCluster** custom resource is the main configuration resource for the Kafka clusters.  
It defines the Apache Kafka cluster properties, like Kafka brokers and listeners configurations.
By deploying the KafkaCluster custom resource, Koperator sets up your Kafka cluster.  
You can change your Kafka cluster properties by updating the KafkaCluster custom resource.
The **KafkaCluster** custom resource always reflects to your Kafka cluster: when something has changed in your KafkaCluster custom resource, Koperator reconciles the changes to your Kafka cluster.

## Schema reference {#schema-ref}

The schema reference for the **KafkaCluster** custom resource is available [here](https://docs.calisti.app/sdm/koperator/reference/crd/kafkaclusters.kafka.banzaicloud.io/).
