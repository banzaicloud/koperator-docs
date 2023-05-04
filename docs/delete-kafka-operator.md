---
title: Delete the operator
linktitle: Uninstall
weight: 950
---

In case you want to delete {{< kafka-operator >}} from your cluster, note that because of dependencies between the various components, they must be deleted in specific order.

{{< warning >}}It’s important to delete the {{< kafka-operator >}} deployment as the last step.
{{< /warning >}}

## Uninstall Koperator

1. Delete the Prometheus instance used by the Kafka cluster. If you used the sample Prometheus instance from the {{< kafka-operator >}} repository you can use the following command, otherwise do this step manually according to the way you deployed the Prometheus instance.

    ```
    kubectl delete \
        -n kafka \
        -f https://raw.githubusercontent.com/banzaicloud/koperator/{{< param "versionnumbers-sdm.koperatorCurrentversion" >}}/config/samples/kafkacluster-prometheus.yaml
    ```

    Expected output:

    ```
    clusterrole.rbac.authorization.k8s.io/prometheus deleted
    clusterrolebinding.rbac.authorization.k8s.io/prometheus deleted
    prometheus.monitoring.coreos.com/kafka-prometheus deleted
    prometheusrule.monitoring.coreos.com/kafka-alerts deleted
    serviceaccount/prometheus deleted
    servicemonitor.monitoring.coreos.com/cruisecontrol-servicemonitor deleted
    servicemonitor.monitoring.coreos.com/kafka-servicemonitor deleted
    ```

1. Delete KafkaCluster Custom Resource (CR) that represent the Kafka cluster and Cruise Control.

    ```
    kubectl delete kafkacluster kafka -n kafka
    ```
    Wait for the Kafka resources (Pods, PersistentVolumeClaims, Configmaps, etc) to be removed

    You would also need to delete other Koperator-managed CRs (if any) following the same fashion

    > Note: KafkaCluster, KafkaTopic and KafkaUser custom resources are protected with Kubernetes finalizers, so those won’t be actually deleted from Kubernetes until the {{< kafka-operator >}} removes those finalizers. After the {{< kafka-operator >}} has finished cleaning up everything, it removes the finalizers. In case you delete the {{< kafka-operator >}} deployment before it cleans up everything, you need to remove the finalizers manually.


1. Uninstall Koperator deployment

    ```
    helm uninstall kafka-operator -n kafka
    ```

1. Delete Koperator Custom Resource Definitions (CRDs)
    ```
    kubectl delete -f https://github.com/banzaicloud/koperator/releases/download/v0.24.1/kafka-operator.crds.yaml
    ```

## Uninstall Zookeeper Operator

1. Delete Zookeeper CR

    ```
    kubectl delete zookeepercluster zookeeper -n zookeeper
    ```
    Wait for the Zookeeper resources (Deployment, PersistentVolumeClaims, Configmaps, etc) to be removed

1. Uninstall Zookeeper Operator deployment

    ```
    helm uninstall zookeeper-operator -n zookeeper
    ```

1. Delete Zookeeper Operator's CRDs

    ```
    kubectl delete customresourcedefinition zookeeperclusters.zookeeper.pravega.io
    ```

## Uninstall Prometheus Operator

### Uninstall directly

1. Delete CR (if any) managed by Prometheus Operator via `kubectl delete`, wait for relevant resources to be removed.

1. Uninstall Prometheus Operator and its CRDs:
    ```
    kubectl delete -n default -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/bundle.yaml
    ```

### Uninstall with Helm

1. Uninstall Prometheus Operator deployment:
    ```
    helm uninstall prometheus -n default
    ```

1. Delete Prometheus Operator's CRDs:
    ```
    kubectl get crd | grep 'monitoring.coreos.com'| awk '{print $1};' | xargs kubectl delete crd
    ```

## Uninstall Cert-Manager

### Uninstall directly

1. Delete CR (if any) managed by Cert-Manager via `kubectl delete`, wait for relevant resources to be removed.

1. Uninstall Cert-Manager and its CRDs:
    ```
    kubectl delete -f https://github.com/jetstack/cert-manager/releases/download/v1.6.2/cert-manager.yaml
    ```

### Uninstall with Helm

1. Delete CR (if any) managed by Cert-Manager via `kubectl delete`, wait for relevant resources to be removed

1. Uninstall Cert-Manager deployment:
    ```
    helm uninstall cert-manager -n cert-manager
    ```
1. Delete Cert-Manager's CRDs:
    ```
    kubectl delete -f https://github.com/jetstack/cert-manager/releases/download/v1.6.2/cert-manager.crds.yaml
    ```