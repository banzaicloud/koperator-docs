---
title: Install the Kafka operator
shorttitle: Install
weight: 10
---

The operator installs the 2.4.0 version of Apache Kafka, and can run on Minikube v0.33.1+ and Kubernetes 1.12.0+.

> The operator supports Kafka 2.0+

As a pre-requisite it needs a Kubernetes cluster (you can create one using [Pipeline](https://github.com/banzaicloud/pipeline)). Also, Kafka requires Zookeeper so you need to first have a Zookeeper cluster if you don't already have one.

The operator also uses `cert-manager` for issuing certificates to users and brokers, so you'll need to have it setup in case you haven't already.

> We believe in the `separation of concerns` principle, thus the Kafka operator does not install nor manage Zookeeper or cert-manager. If you would like to have a fully automated and managed experience of Apache Kafka on Kubernetes please try it with [Pipeline](https://github.com/banzaicloud/pipeline).

#### Install the operator and all requirements using Supertubes

Go grab and install the [Supertubes](https://banzaicloud.com/docs/supertubes/overview/) CLI tool.

```bash
curl https://getsupertubes.sh | sh
```

Run the following command:

```bash
supertubes install -a
```

#### Install the operator and the requirements independently

##### Install cert-manager

> Cert-manager 0.11.x introduced some API changes. We did not want to drop the 0.10.x line support so we decided to create two releases for the Operator.

- Operator 0.8.x line supports cert-manager 0.11.x
- Operator 0.7.x line supports cert-manager 0.10.x

Install cert-manager and CustomResourceDefinitions

```bash
# Install the CustomResourceDefinitions and cert-manager itself
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.11.0/cert-manager.yaml
```

Or install with helm

```bash
# Install CustomResourceDefinitions first
kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.11/deploy/manifests/00-crds.yaml

# Add the jetstack helm repo
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install cert-manager into the cluster
# Using helm3
# You have to create the namespace before executing following command
helm install cert-manager --namespace cert-manager --version v0.11.0 jetstack/cert-manager
# Using previous versions of helm
helm install --name cert-manager --namespace cert-manager --version v0.11.0 jetstack/cert-manager
```

##### Install Zookeeper

To install Zookeeper we recommend using the [Pravega's Zookeeper Operator](https://github.com/pravega/zookeeper-operator).
You can deploy Zookeeper by using the Helm chart which can be found here [chart](https://github.com/pravega/zookeeper-operator/tree/master/charts/zookeeper-operator).

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

##### Install Prometheus-operator

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

##### Install Operator with Kustomize

We recommend to use a **custom StorageClass** to leverage the volume binding mode `WaitForFirstConsumer`

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

> In this case you have to install Prometheus with proper configuration if you want the Kafka-Operator to react to alerts. Again, if you need Prometheus and would like to have a fully automated and managed experience of Apache Kafka on Kubernetes please try it with [Pipeline](https://github.com/banzaicloud/pipeline).

##### Easy way: installing with Helm

Alternatively, if you are using Helm, you can deploy the operator using a Helm chart [Helm chart](https://github.com/banzaicloud/kafka-operator/tree/master/charts):

> To install the 0.7.x version of the operator use `helm install --name=kafka-operator --namespace=kafka --set operator.image.tag=0.7.x banzaicloud-stable/kafka-operator`

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

> In this case Prometheus will be installed and configured properly for the Kafka-Operator.

## Test Your Deployment

For simple test code please check out the [test docs](docs/test.md)

For a more in-depth view at using SSL and the `KafkaUser` CRD see the [SSL docs](docs/ssl.md)

For creating topics via with `KafkaTopic` CRD there is an example and more information in the [topics docs](docs/topics.md)
