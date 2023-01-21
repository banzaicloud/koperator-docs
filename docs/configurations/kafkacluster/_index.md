---
title: Kafka cluster configuration
shorttitle: KafkaCluster
weight: 7000
---

## Overview

The **KafkaCluster** custom resource is the main configuration resource for Koperator.  
It defines the Kafka cluster properties like Kafka brokers and listeners configurations.  
By deploying the KafkaCluster custom resource, Koperator sets up your Kafka cluster.  
You can also change your Kafka cluster properties by updating the **KafkaCluster** custom resource.
**KafkaCluster** custom resource always reflects to your Kafka cluster.  
It means when something has changed in your KafkaCluster custom resource, Koperator applies the changes to your Kafka cluster.

## Contents

1. [Schema reference](#schema-ref)

### 1. Schema reference {#schema-ref}

The schema reference for the **KafkaCluster** custom resource is available [here](https://smm-docs.eticloud.io/sdm/koperator/reference/crd/kafkaclusters.kafka.banzaicloud.io/).
