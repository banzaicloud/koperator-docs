---
title: Common errors
weight: 100
---

## Upgrade failed

If you get the following error in the logs of {{< kafka-operator >}}, update your KafkaCluster CRD. This error typically occurs when you upgrade your {{< kafka-operator >}} to a new version, but forget to update the KafkaCluster CRD.

```bash
Error: UPGRADE FAILED: cannot patch "kafka" with kind KafkaCluster: KafkaCluster.kafka.banzaicloud.io "kafka" is invalid
```

The recommended way to upgrade {{< kafka-operator >}} is to upgrade the KafkaCluster CRD, then update {{< kafka-operator >}}. For details, see {{% xref "/docs/sdm/koperator/upgrade-kafka-operator.md" %}}.
