---
title: Install the Kafka operator
shorttitle: Install
weight: 10
---

{{< contents >}}

The operator installs the 2.5.0 version of Apache Kafka, and can run on Minikube v0.33.1+ and Kubernetes 1.15.0+.

> The operator supports Kafka 2.0+

## Prerequisites

- A Kubernetes cluster. You can create one using the [Banzai Cloud Pipeline platform](/products/pipeline/), or any other tool of your choice.
- Kafka requires Zookeeper, so you need to first have a Zookeeper cluster if you don't already have one.
- The Kafka operator uses `cert-manager` for issuing certificates to users and brokers, so you'll need to have it setup in case you haven't already.

> We believe in the `separation of concerns` principle, thus the Kafka operator does not install nor manage Zookeeper or cert-manager. If you would like to have a fully automated and managed experience of Apache Kafka on Kubernetes, try the [Banzai Cloud Pipeline platform](/products/pipeline/).

## Install Kafka operator and all requirements using Supertubes

1. Download the [Supertubes](/docs/supertubes/overview/) CLI tool.

    ```bash
    curl https://getsupertubes.sh | sh
    ```

1. Run the following command:

    ```bash
    supertubes install -a
    ```

## Install Kafka operator and the requirements independently

### Install cert-manager

Cert-manager version 0.15.x introduced some API changes:

- Kafka operator 0.8.x and newer supports cert-manager 0.15.x
- Kafka operator 0.7.x supports cert-manager 0.10.x

Install cert-manager and CustomResourceDefinitions using one of the following methods:

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
    # You have to create the namespace before executing following command
    helm install cert-manager --namespace cert-manager --version v0.15.1 jetstack/cert-manager
    # Using previous versions of helm
    helm install --name cert-manager --namespace cert-manager --version v0.15.1 jetstack/cert-manager
    ```

### Install Zookeeper

To install Zookeeper we recommend using the [Pravega's Zookeeper Operator](https://github.com/pravega/zookeeper-operator). You can deploy Zookeeper by using this [Helm chart](https://github.com/pravega/zookeeper-operator/tree/master/charts/zookeeper-operator).

```bash
# Deprecated, please use Pravega's helm chart
helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com/
# Using helm3
# You have to create the namespace before executing following command
helm install zookeeper-operator --namespace=zookeeper banzaicloud-stable/zookeeper-operator
# Using previous versions of helm
# Deprecated, please use Pravega's helm chart
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

Install the Operator and CustomResourceDefinitions to the `default` namespace

```bash
# Install Prometheus-operator and CustomResourceDefinitions
kubectl apply -n default -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/bundle.yaml
```

Or install with helm

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
# You have to create the namespace before executing following command
helm install test --namespace default stable/prometheus-operator \
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

```bash
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

1. Set `KUBECONFIG` pointing towards your cluster
2. Run `make deploy` (deploys the operator in the `kafka` namespace into the cluster)
3. Set your Kafka configurations in a Kubernetes custom resource (sample: `config/samples/simplekafkacluster.yaml`) and run this command to deploy the Kafka components:

```bash
# Add your zookeeper svc name to the configuration
kubectl create -n kafka -f config/samples/simplekafkacluster.yaml
# If prometheus operator installed create the ServiceMonitors
kubectl create -n default -f config/samples/kafkacluster-prometheus.yaml
```

> In this case you have to install Prometheus with proper configuration if you want the Kafka operator to react to alerts. Again, if you need Prometheus and would like to have a fully automated and managed experience of Apache Kafka on Kubernetes please try it with the [Banzai Cloud Pipeline platform](/products/pipeline/).

#### Install the Kafka operator with Helm {#kafka-operator-helm}

You can deploy the Kafka operator using a Helm chart [Helm chart](https://github.com/banzaicloud/kafka-operator/tree/master/charts) by running the following commands.

- If you are using cert-manager 0.10.x and want to install the 0.7.x version of the operator, run the following command: `helm install --name=kafka-operator --namespace=kafka --set operator.image.tag=0.7.x banzaicloud-stable/kafka-operator`
- Otherwise, run the following commands:

    ```bash
    helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com/
    # Using helm3
    # You have to create the namespace before executing following command
    helm install kafka-operator --namespace=kafka banzaicloud-stable/kafka-operator
    # Using previous versions of helm
    helm install --name=kafka-operator --namespace=kafka banzaicloud-stable/kafka-operator
    # Add your zookeeper svc name to the configuration
    kubectl create -n kafka -f config/samples/simplekafkacluster.yaml
    # If prometheus operator installed create the ServiceMonitors
    kubectl create -n kafka -f config/samples/kafkacluster-prometheus.yaml
    ```

    In this case Prometheus will be installed and configured properly for the Kafka operator.

## Test Your Deployment

- For simple test, check the [test docs](../test/)
- For a more in-depth view at using SSL and the `KafkaUser` CRD, see the [SSL docs](../ssl/)
- To create topics via with `KafkaTopic` CRD there is an example and more information in the [topics docs](../topics/)
