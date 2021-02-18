---
title: Upgrade the Kafka operator
shorttitle: Upgrade
weight: 15
---

When upgrading your Kafka operator deployment to a new version, complete the following steps.

1. Download the CRDs for the new release from the [Kafka operator releases page](https://github.com/banzaicloud/kafka-operator/releases). They are included in the assets of the release.

    {{< warning >}}**Hazard of data loss** Do not delete the old CRD from the cluster. Deleting the CRD removes your Kafka cluster.{{< /warning >}}

1. Replace the KafkaCluster CRD with the new one on your cluster by running the following command (replace &lt;versionnumber> with the release you are upgrading to, for example, **v0.14.0**).

    ```bash
    kubectl replace --validate=false -f https://github.com/banzaicloud/kafka-operator/releases/download/<versionnumber>/kafka-operator.crds.yaml
    ```

1. Update the Kafka operator by running:

    ```bash
    helm repo update
    helm upgrade kafka-operator --namespace=kafka banzaicloud-stable/kafka-operator
    ```
