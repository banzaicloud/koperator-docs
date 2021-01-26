---
title: Install the Kafka operator
shorttitle: Install
weight: 10
---



The operator installs the 2.5.0 version of Apache Kafka, and can run on Minikube v0.33.1+ and Kubernetes 1.15.0+.

> The operator supports Kafka 2.0+

## Prerequisites

- A Kubernetes cluster. You can create one using the [Banzai Cloud Pipeline platform](/products/pipeline/), or any other tool of your choice.

> We believe in the `separation of concerns` principle, thus the Kafka operator does not install nor manage Zookeeper or cert-manager. If you would like to have a fully automated and managed experience of Apache Kafka on Kubernetes, try [Banzai Cloud Supertubes](/products/supertubes/).

## Install Kafka operator and all requirements using Supertubes

This method uses a command-line tool of the commercial [Banzai Cloud Supertubes](/products/supertubes/) product to install the Kafka operator and its prerequisites. If you'd prefer to install these components manually, see [Install Kafka operator and the requirements independently](#manual-install).

1. [Register for an evaluation version of Supertubes](/products/try-supertubes/).

1. Install the [Supertubes](/docs/supertubes/overview/) CLI tool for your environment by running the following command:

    ```bash
    curl https://getsupertubes.sh | sh
    ```

1. Run the following command:

    ```bash
    supertubes install -a
    ```

## Install Kafka operator and the requirements independently {#manual-install}

### Install cert-manager {#install-cert-manager}

The Kafka operator uses [cert-manager](https://cert-manager.io) for issuing certificates to clients and brokers. Deploy and configure cert-manager if you haven't already done so.

> Note:
>
> - Kafka operator 0.8.x and newer supports cert-manager 0.15.x
> - Kafka operator 0.7.x supports cert-manager 0.10.x

Install cert-manager and the CustomResourceDefinitions using one of the following methods:

- Directly:

    ```bash
    # Install the CustomResourceDefinitions and cert-manager itself
    kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.15.1/cert-manager.yaml
    ```

- Using Helm:

    ```bash

    # Add the jetstack helm repo
    helm repo add jetstack https://charts.jetstack.io
    helm repo update

    # Install cert-manager into the cluster
    # Using helm3
    helm install cert-manager --namespace cert-manager --create-namespace --version v0.15.1 jetstack/cert-manager

    # Install the CustomResourceDefinitions
    kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.15.1/cert-manager.crds.yaml
    ```

### Install Zookeeper {#install-zookeeper}

Kafka requires [Zookeeper](https://zookeeper.apache.org). Deploy a Zookeeper cluster if you don't already have one.

> Note: You are recommended to create a separate Zookeeper deployment for each Kafka cluster. If you want to share the same Zookeeper cluster across multiple Kafka cluster instances, use a unique zk path in the KafkaCluster CR to avoid conflicts (even with previous defunct KafkaCluster instances).

Install Zookeeper using one of the following methods:

- **Recommended**: Install Zookeeper using the [Pravega's Zookeeper Operator](https://github.com/pravega/zookeeper-operator).

    ```bash
    helm repo add pravega https://charts.pravega.io
    helm repo update
    helm install zookeeper-operator --namespace=zookeeper --create-namespace pravega/zookeeper-operator
    ```

- **Deprecated**: Run the following commands to install Zookeeper:

    ```bash
    # Deprecated method, use Pravega's helm chart if possible
    helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com/
    # Using helm3
    helm install zookeeper-operator --namespace=zookeeper --create-namespace banzaicloud-stable/zookeeper-operator
    # Using previous versions of helm
    helm install --name zookeeper-operator --namespace=zookeeper banzaicloud-stable/zookeeper-operator
    kubectl create --namespace zookeeper -f - <<EOF
    apiVersion: zookeeper.pravega.io/v1beta1
    kind: ZookeeperCluster
    metadata:
      name: zookeeper
      namespace: zookeeper
    spec:
      replicas: 3
    EOF
    ```

### Install Prometheus-operator

Install the [Prometheus operator](https://github.com/prometheus-operator/prometheus-operator) and its CustomResourceDefinitions to the `default` namespace.

- Directly:

    ```bash
    kubectl apply -n default -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/bundle.yaml
    ```

- Using Helm:

    ```bash
    # Install CustomResourceDefinitions
    kubectl apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
    kubectl apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
    kubectl apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
    kubectl apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
    kubectl apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
    kubectl apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml


    # Install only the Prometheus-operator
    # Using helm3
    helm install test --namespace default stable/prometheus-operator
    # Using previous versions of helm
    helm install --name test --namespace default stable/prometheus-operator \
    --set prometheusOperator.createCustomResource=false \
    --set defaultRules.enabled=false \
    --set alertmanager.enabled=false \
    --set grafana.enabled=false \
    --set kubeApiServer.enabled=false \
    --set kubelet.enabled=false \
    --set kubeControllerManager.enabled=false \
    --set coreDNS.enabled=false \
    --set kubeEtcd.enabled=false \
    --set kubeScheduler.enabled=false \
    --set kubeProxy.enabled=false \
    --set kubeStateMetrics.enabled=false \
    --set nodeExporter.enabled=false \
    --set prometheus.enabled=false
    ```

### Install the Kafka operator

If you want to install the Kafka operator separately, use one of the following methods:

- [Install the Kafka operator with Kustomize](#kafka-operator-kustomize)
- [Install the Kafka operator with Helm](#kafka-operator-helm)

#### Install the Kafka operator with Kustomize {#kafka-operator-kustomize}

We recommend using a **custom StorageClass** to leverage the volume binding mode `WaitForFirstConsumer`

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: exampleStorageclass
parameters:
  type: pd-standard
provisioner: kubernetes.io/gce-pd
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```

> Remember to set your Kafka CR properly to use the newly created StorageClass.

1. Point your `KUBECONFIG` to your cluster.
2. Run `make deploy` (deploys the operator in the `kafka` namespace into the cluster)
3. Set your Kafka configurations in a Kubernetes custom resource [see this sample in the project repository](https://github.com/banzaicloud/kafka-operator/blob/master/config/samples/simplekafkacluster.yaml)
4. Run this command to deploy the Kafka components:

    ```bash
    # Add your zookeeper svc name to the configuration
    kubectl create -n kafka -f config/samples/simplekafkacluster.yaml
    # If prometheus operator installed create the ServiceMonitors
    kubectl create -n default -f config/samples/kafkacluster-prometheus.yaml
    ```

> In this case you have to install Prometheus with proper configuration if you want the Kafka operator to react to alerts. Again, if you need Prometheus and would like to have a fully automated and managed experience of Apache Kafka on Kubernetes, try [Banzai Cloud Supertubes](/products/supertubes/).

#### Install the Kafka operator with Helm {#kafka-operator-helm}

You can deploy the Kafka operator using a [Helm chart](https://github.com/banzaicloud/kafka-operator/tree/master/charts). Complete the following steps.

1. Install the kafka-operator CustomResourceDefinition resources (adjust the version number to the Kafka operator release you want to install). This is performed in a separate step to allow you to easily uninstall and reinstall kafka-operator without deleting your installed custom resources.

    ```bash
    kubectl apply --validate=false -f https://github.com/banzaicloud/kafka-operator/releases/download/v0.14.0/kafka-operator.crds.yaml
    ```

1. Add the Banzai Cloud repository to Helm.

    ```bash
    helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com/
    helm repo update
    ```

1. Install the Kafka operator into the *kafka* namespace:

    - Using Helm 3:

        ```bash
        helm install kafka-operator --namespace=kafka --create-namespace banzaicloud-stable/kafka-operator
        ```

    - Using previous versions of Helm:

        ```bash
        helm install --name=kafka-operator --namespace=kafka banzaicloud-stable/kafka-operator
        ```

1. Add your zookeeper service name to the configuration.

    ```bash
    kubectl create -n kafka -f https://raw.githubusercontent.com/banzaicloud/kafka-operator/master/config/samples/simplekafkacluster.yaml
    ```

1. If you have installed the Prometheus operator, create the ServiceMonitors. Prometheus will be installed and configured properly for the Kafka operator.

    ```bash
    kubectl create -n kafka -f https://raw.githubusercontent.com/banzaicloud/kafka-operator/master/config/samples/kafkacluster-prometheus.yaml
    ```

## Test your deployment

- For a simple test, see [Test provisioned Kafka Cluster](../test/).
- For a more in-depth view at using SSL and the `KafkaUser` CRD, see [Securing Kafka With SSL](../ssl/).
- To create topics via with the `KafkaTopic` CRD, see [Provisioning Kafka Topics](../topics/).
