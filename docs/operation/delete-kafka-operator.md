---
title: Delete Kafka operator
shorttitle: Delete operator
weight: 950
---

In case you want to delete the Kafka operator from your cluster, note that because of dependencies between the various components, they must be deleted in specific order.

{{< warning >}}It’s important to delete the kafka-operator deployment as the last step.
{{< /warning >}}

1. Delete the *KafkaCluster* custom resources that represent the Kafka cluster and Cruise Control.
1. Wait until kafka-operator deletes all resources.  Note that KafkaCluster, KafkaTopic and KafkaUser custom resources are protected with kubernetes finalizers, so those won’t be actually deleted from Kubernetes until the kafka-operator removes those finalizers. After the kafka-operator has finished cleaning up everything, it removes the finalizers. In case you delete the kafka-operator deployment before it cleans up everything you need to remove the finalizers manually.
1. Delete the kafka-operator deployment.
