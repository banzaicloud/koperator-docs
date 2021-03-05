---
title: Install the Kafka operator
shorttitle: Install
weight: 10
---



The operator installs the 2.5.0 version of Apache Kafka, and can run on Minikube v0.33.1+ and Kubernetes 1.15.0+.

> The operator supports Kafka 2.0+

## Prerequisites

- A Kubernetes cluster (minimum 6 vCPU and 10 GB RAM). You can create one using the [Banzai Cloud Pipeline platform](/products/pipeline/), or any other tool of your choice.

> We believe in the `separation of concerns` principle, thus the Kafka operator does not install nor manage Zookeeper or cert-manager. If you would like to have a fully automated and managed experience of Apache Kafka on Kubernetes, try [Banzai Cloud Supertubes](/products/supertubes/).

## Install Kafka operator and all requirements using Supertubes

This method uses a command-line tool of the commercial [Banzai Cloud Supertubes](/products/supertubes/) product to install the Kafka operator and its prerequisites. If you'd prefer to install these components manually, see [Install Kafka operator and the requirements independently](#manual-install).

1. [Register for an evaluation version of Supertubes](/products/try-supertubes/).

1. Install the [Supertubes](/docs/supertubes/overview/) CLI tool for your environment by running the following command:

    {{< include-headless "download-supertubes.md" >}}

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
    kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.15.2/cert-manager.yaml
    ```

- Using Helm:

    ```bash

    # Add the jetstack helm repo
    helm repo add jetstack https://charts.jetstack.io
    helm repo update

    # Install cert-manager into the cluster
    # Using helm3
    helm install cert-manager --namespace cert-manager --create-namespace --version v0.15.2 jetstack/cert-manager

    # Install the CustomResourceDefinitions
    kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.15.2/cert-manager.crds.yaml

Verify that the cert-manager pods have been created:

```bash
kubectl get pods -n cert-manager
```

Expected output:

```bash
NAME                                      READY   STATUS    RESTARTS   AGE
cert-manager-7747db9d88-vgggn             1/1     Running   0          29m
cert-manager-cainjector-87c85c6ff-q945h   1/1     Running   1          29m
cert-manager-webhook-64dc9fff44-2p6tx     1/1     Running   0          29m
```

### Install Zookeeper {#install-zookeeper}

Kafka requires [Zookeeper](https://zookeeper.apache.org). Deploy a Zookeeper cluster if you don't already have one.

> Note: You are recommended to create a separate Zookeeper deployment for each Kafka cluster. If you want to share the same Zookeeper cluster across multiple Kafka cluster instances, use a unique zk path in the KafkaCluster CR to avoid conflicts (even with previous defunct KafkaCluster instances).

1. Install Zookeeper using the [Pravega's Zookeeper Operator](https://github.com/pravega/zookeeper-operator).

    ```bash
    helm repo add pravega https://charts.pravega.io
    helm repo update
    helm install zookeeper-operator --namespace=zookeeper --create-namespace pravega/zookeeper-operator
    ```

1. Create a Zookeeper cluster.

    {{< include-code "create-zookeeper.sample" "bash" >}}

1. Verify that Zookeeper has beeb deployed.

    ```bash
    kubectl get pods -n zookeeper
    ```

    Expected output:

    ```bash
    NAME                                  READY   STATUS    RESTARTS   AGE
    zookeeper-0                           1/1     Running   0          27m
    zookeeper-operator-54444dbd9d-2tccj   1/1     Running   0          28m
    ```

### Install Prometheus-operator

Install the [Prometheus operator](https://github.com/prometheus-operator/prometheus-operator) and its CustomResourceDefinitions to the `default` namespace.

- Directly:

    ```bash
    kubectl apply -n default -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/bundle.yaml
    ```

- Using Helm:

    Add the prometheus repository to Helm:

    ```bash
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update

    ```

    Install only the Prometheus-operator:

    ```bash
    helm install prometheus --namespace default prometheus-community/kube-prometheus-stack \
    --set prometheusOperator.createCustomResource=true \
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

### Install the Kafka operator with Helm {#kafka-operator-helm}

You can deploy the Kafka operator using a [Helm chart](https://github.com/banzaicloud/kafka-operator/tree/master/charts). Complete the following steps.

1. Install the kafka-operator CustomResourceDefinition resources (adjust the version number to the Kafka operator release you want to install). This is performed in a separate step to allow you to easily uninstall and reinstall kafka-operator without deleting your installed custom resources.

    ```bash
    kubectl create --validate=false -f https://github.com/banzaicloud/kafka-operator/releases/download/v0.15.1/kafka-operator.crds.yaml
    ```

1. Add the Banzai Cloud repository to Helm.

    ```bash
    helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com/
    helm repo update
    ```

1. Install the Kafka operator into the *kafka* namespace:

    ```bash
    helm install kafka-operator --namespace=kafka --create-namespace banzaicloud-stable/kafka-operator
    ```

1. Create the Kafka cluster using the KafkaCluster custom resource. You can find various examples for the custom resource in the [Kafka operator repository](https://github.com/banzaicloud/kafka-operator/tree/master/config/samples).

    {{< include-headless "warning-listener-protocol.md" "supertubes/kafka-operator" >}}

    - To create a sample Kafka cluster that allows unencrypted client connections, run the following command:

        ```bash
        kubectl create -n kafka -f https://raw.githubusercontent.com/banzaicloud/kafka-operator/master/config/samples/simplekafkacluster.yaml
        ```

    - To create a sample Kafka cluster that allows TLS-encrypted client connections, run the following command. For details on the configuration parameters related to SSL, see {{% xref "/docs/supertubes/kafka-operator/ssl.md#enable-ssl" %}}.

        ```bash
        kubectl create -n kafka -f https://raw.githubusercontent.com/banzaicloud/kafka-operator/master/config/samples/simplekafkacluster_ssl.yaml
        ```

1. If you have installed the Prometheus operator, create the ServiceMonitors. Prometheus will be installed and configured properly for the Kafka operator.

    ```bash
    kubectl create -n kafka -f https://raw.githubusercontent.com/banzaicloud/kafka-operator/master/config/samples/kafkacluster-prometheus.yaml
    ```

1. Verify that the Kafka cluster has been created.

    ```bash
    kubectl get pods -n kafka
    ```

    Expected output:

    ```bash
    NAME                                      READY   STATUS    RESTARTS   AGE
    kafka-0-nvx8c                             1/1     Running   0          16m
    kafka-1-swps9                             1/1     Running   0          15m
    kafka-2-lppzr                             1/1     Running   0          15m
    kafka-cruisecontrol-fb659b84b-7cwpn       1/1     Running   0          15m
    kafka-operator-operator-8bb75c7fb-7w4lh   2/2     Running   0          17m
    prometheus-kafka-prometheus-0             2/2     Running   1          16m
    ```

## Test your deployment

- For a simple test, see [Test provisioned Kafka Cluster](../test/).
- For a more in-depth view at using SSL and the `KafkaUser` CRD, see [Securing Kafka With SSL](../ssl/).
- To create topics via with the `KafkaTopic` CRD, see [Provisioning Kafka Topics](../topics/).
