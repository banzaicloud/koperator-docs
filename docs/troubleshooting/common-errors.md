---
title: Common errors
weight: 100
---

## Upgrade failed

If you get the following error in the logs of the Kafka operator, update your KafkaCluster CRD. This error typically occurs when you upgrade your Kafka operator to a new version, but forget to update the KafkaCluster CRD.

```bash
Error: UPGRADE FAILED: cannot patch "kafka" with kind KafkaCluster: KafkaCluster.kafka.banzaicloud.io "kafka" is invalid: [status.brokersState.2.perBrokerConfigurationState: Required value, status.brokersState.3.perBrokerConfigurationState: Required value, status.brokersState.4.perBrokerConfigurationState: Required value, status.brokersState.0.perBrokerConfigurationState: Required value, status.brokersState.1.perBrokerConfigurationState: Required value]
```

The recommended way to upgrade the Kafka operator is to upgrade the KafkaCluster CRD, then update the Kafka operator. For details, see {{% xref "/docs/supertubes/kafka-operator/upgrade-kafka-operator.md" %}}.
