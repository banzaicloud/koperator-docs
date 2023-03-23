---
title: Install the operator
shorttitle: Install
weight: 10
---



The operator installs version 3.1.0 of Apache Kafka, and can run on Minikube v0.33.1+ and Kubernetes 1.21-1.24.

> The operator supports Kafka 2.6.2-3.1.x.

{{< include-headless "warning-ebs-csi-driver.md" "supertubes/kafka-operator" >}}


## Prerequisites

- A Kubernetes cluster (minimum 6 vCPU and 10 GB RAM). Red Hat OpenShift is also supported in {{< kafka-operator >}} version 0.23 and newer, but note that it needs some permissions for certain components to function.

> We believe in the `separation of concerns` principle, thus the {{< kafka-operator >}} does not install nor manage Zookeeper or cert-manager. If you would like to have a fully automated and managed experience of Apache Kafka on Kubernetes, try [Banzai Cloud Supertubes](/products/supertubes/).

## Install {{< kafka-operator >}} and all requirements using Supertubes

This method uses a command-line tool of the commercial [Banzai Cloud Supertubes](/products/supertubes/) product to install the {{< kafka-operator >}} and its prerequisites. If you'd prefer to install these components manually, see [Install {{< kafka-operator >}} and the requirements independently](#manual-install).

1. [Register for an evaluation version of Supertubes](/products/try-supertubes/).

1. Install the [Supertubes](/docs/supertubes/overview/) CLI tool for your environment by running the following command:

    {{< include-headless "download-supertubes.md" >}}

1. Run the following command:

    ```bash
    supertubes install -a
    ```

## Install {{< kafka-operator >}} and its requirements independently {#install-kafka-operator-and-its-requirements-independently}

### Install cert-manager with Helm {#install-cert-manager-with-helm}

{{< kafka-operator >}} uses [cert-manager](https://cert-manager.io) for issuing certificates to clients and brokers and cert-manager is required for TLS-encrypted client connections. It is recommended to deploy and configure a cert-manager instance if there is none in your environment yet.

> Note:
> - {{< kafka-operator >}} 0.18.1 and newer supports cert-manager 1.5.3-1.9.x
> - {{< kafka-operator >}} 0.8.x-0.17.0 supports cert-manager 1.3.x

1. Install cert-manager's CustomResourceDefinitions.

    kubectl apply \
    --validate=false \
    -f https://github.com/jetstack/cert-manager/releases/download/v1.11.0/cert-manager.crds.yaml
    ```

    Expected output:

    ```bash
    customresourcedefinition.apiextensions.k8s.io/certificaterequests.cert-manager.io created
    customresourcedefinition.apiextensions.k8s.io/certificates.cert-manager.io created
    customresourcedefinition.apiextensions.k8s.io/challenges.acme.cert-manager.io created
    customresourcedefinition.apiextensions.k8s.io/clusterissuers.cert-manager.io created
    customresourcedefinition.apiextensions.k8s.io/issuers.cert-manager.io created
    customresourcedefinition.apiextensions.k8s.io/orders.acme.cert-manager.io created
    ```

1. Install cert-manager.

    ```bash
    helm install \
    cert-manager \
    --repo https://charts.jetstack.io cert-manager \
    --version v1.11.0 \
    --namespace cert-manager \
    --create-namespace \
    --atomic \
    --debug
    ```

    Expected output:

    ```bash
    install.go:194: [debug] Original chart version: "v1.11.0"
    install.go:211: [debug] CHART PATH: /Users/pregnor/.cache/helm/repository/cert-manager-v1.11.0.tgz

    # ...
    NAME: cert-manager
    LAST DEPLOYED: Thu Mar 23 08:40:07 2023
    NAMESPACE: cert-manager
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    USER-SUPPLIED VALUES:
    {}

    COMPUTED VALUES:
    # ...
    NOTES:
    cert-manager v1.11.0 has been deployed successfully!

    In order to begin issuing certificates, you will need to set up a ClusterIssuer
    or Issuer resource (for example, by creating a 'letsencrypt-staging' issuer).

    More information on the different types of issuers and how to configure them
    can be found in our documentation:

    https://cert-manager.io/docs/configuration/

    For information on how to configure cert-manager to automatically provision
    Certificates for Ingress resources, take a look at the `ingress-shim`
    documentation:

    https://cert-manager.io/docs/usage/ingress/
    ```

1. Verify that cert-manager has been deployed and is in running state.

    ```bash
    kubectl get pods -n cert-manager
    ```

    Expected output:

    ```bash
    NAME                                      READY   STATUS    RESTARTS   AGE
    cert-manager-6b4d84674-4pkh4               1/1     Running   0          117s
    cert-manager-cainjector-59f8d9f696-wpqph   1/1     Running   0          117s
    cert-manager-webhook-56889bfc96-x8szj      1/1     Running   0          117s
    ```

### Install zookeeper-operator with Helm {#install-zookeeper-operator-with-helm}

{{< kafka-operator >}} requires [Zookeeper](https://zookeeper.apache.org) for Kafka operations. It is required to deploy zookeeper-operator if your environment doesn't have an instance of it yet and it is also required to create a Zookeeper cluster if there is none in your environment yet for your Kafka cluster.

> Note: It is recommended to create a separate Zookeeper deployment for each Kafka cluster. To share the same Zookeeper cluster across multiple Kafka cluster instances, use a unique zk path in the KafkaCluster CR to avoid conflicts (even with previous defunct KafkaCluster instances).

1. Install Zookeeper using the [Pravega's Zookeeper Operator](https://github.com/pravega/zookeeper-operator).

    ```bash
    helm install \
    zookeeper-operator \
    --repo https://charts.pravega.io zookeeper-operator \
    --version 0.2.14 \
    --namespace=zookeeper \
    --create-namespace \
    --atomic \
    --debug
    ```

    Expected output:

    ```bash
    install.go:194: [debug] Original chart version: "0.2.14"
    install.go:211: [debug] CHART PATH: /Users/pregnor/.cache/helm/repository/zookeeper-operator-0.2.14.tgz

    # ...
    NAME: zookeeper-operator
    LAST DEPLOYED: Thu Mar 23 08:42:42 2023
    NAMESPACE: zookeeper
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    USER-SUPPLIED VALUES:
    {}

    COMPUTED VALUES:
    # ...

    ```

1. Verify that zookeeper-operator has been deployed and is in running state.

    ```bash
    kubectl get pods --namespace zookeeper
    ```

    Expected output:

    ```bash
    NAME                                  READY   STATUS    RESTARTS   AGE
    zookeeper-operator-5857967dcc-gm5l5   1/1     Running   0          3m22s
    ```

### Deploy a Zookeeper cluster for Kafka {#deploy-a-zookeeper-cluster-for-kafka}

1. Create a Zookeeper cluster.

    {{< include-code "create-zookeeper.sample" "bash" >}}

1. Verify that Zookeeper has been deployed and is in running state with the configured number of replicas.

    ```bash
    kubectl get pods -n zookeeper
    ```

    Expected output:

    ```bash
    NAME                                  READY   STATUS    RESTARTS   AGE
    zookeeper-0                           1/1     Running   0          27m
    zookeeper-operator-54444dbd9d-2tccj   1/1     Running   0          28m
    ```

### Install prometheus-operator with Helm {#install-prometheus-operator-with-helm}

{{< kafka-operator >}} uses [Prometheus](https://prometheus.io/) for exporting metrics of the Kafka cluster. It is recommended to deploy a Prometheus instance if you don't one yet.

1. Install the [Prometheus operator](https://github.com/prometheus-operator/prometheus-operator) and its CustomResourceDefinitions to the `prometheus` namespace.

    ```bash
    helm install prometheus \
    --repo https://prometheus-community.github.io/helm-charts kube-prometheus-stack \
    --version 42.0.1 \
    --namespace prometheus \
    --create-namespace \
    --atomic \
    --debug \
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

    Expected output:

    ```bash
    install.go:194: [debug] Original chart version: "45.7.1"
    install.go:211: [debug] CHART PATH: /Users/pregnor/.cache/helm/repository/kube-prometheus-stack-45.7.1.tgz

    # ...
    NAME: prometheus
    LAST DEPLOYED: Thu Mar 23 09:28:29 2023
    NAMESPACE: prometheus
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    USER-SUPPLIED VALUES:
    # ...

    COMPUTED VALUES:
    # ...
    NOTES:
    kube-prometheus-stack has been installed. Check its status by running:
        kubectl --namespace prometheus get pods -l "release=prometheus"

    Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.
    ```

1. Verify that prometheus-operator has been deployed and is in running state.

    ```bash
    kubectl get pods -n prometheus
    ```

    Expected output:

    ```bash
    NAME                                                   READY   STATUS    RESTARTS   AGE
    prometheus-kube-prometheus-operator-646d5fd7d5-s72jn   1/1     Running   0          15m
    ```

### Install {{< kafka-operator >}} with Helm {#install-kafka-operator-with-helm}

{{< kafka-operator >}} can be deployed using its [Helm chart](https://github.com/banzaicloud/koperator/tree/{{< param "versionnumbers-sdm.koperatorCurrentversion" >}}/charts).

1. Install the {{< kafka-operator >}} CustomResourceDefinition resources (adjust the version number to the {{< kafka-operator >}} release you want to install). This is performed in a separate step to allow you to uninstall and reinstall {{< kafka-operator >}} without deleting your installed custom resources.

    ```bash
    kubectl create \
    --validate=false \
    -f https://github.com/banzaicloud/koperator/releases/download/v{{< param "versionnumbers-sdm.koperatorCurrentversion" >}}/kafka-operator.crds.yaml
    ```

    Expected output:

    ```bash
    customresourcedefinition.apiextensions.k8s.io/cruisecontroloperations.kafka.banzaicloud.io created
    customresourcedefinition.apiextensions.k8s.io/kafkaclusters.kafka.banzaicloud.io created
    customresourcedefinition.apiextensions.k8s.io/kafkatopics.kafka.banzaicloud.io created
    customresourcedefinition.apiextensions.k8s.io/kafkausers.kafka.banzaicloud.io created
    ```

1. Install {{< kafka-operator >}} into the *kafka* namespace:

    ```bash
    helm install \
    kafka-operator \
    --repo https://kubernetes-charts.banzaicloud.com kafka-operator \
    --version {{< param "versionnumbers-sdm.koperatorCurrentversion" >}}
    --namespace=kafka \
    --create-namespace \
    --atomic \
    --debug
    ```

    Expected output:

    ```bash
    install.go:194: [debug] Original chart version: ""
    install.go:211: [debug] CHART PATH: /Users/pregnor/development/src/github.com/banzaicloud/koperator/kafka-operator-{{< param "versionnumbers-sdm.koperatorCurrentversion" >}}.tgz

    # ...
    NAME: kafka-operator
    LAST DEPLOYED: Thu Mar 23 10:05:11 2023
    NAMESPACE: kafka
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    USER-SUPPLIED VALUES:
    # ...
    ```

1. Verify that koperator has been deployed and is in running state.

    ```bash
    kubectl get pods -n kafka
    ```

    Expected output:

    ```bash
    NAME                                       READY   STATUS    RESTARTS   AGE
    kafka-operator-operator-8458b45587-286f9   2/2     Running   0          62s
    ```

### Deploy a Kafka cluster {#deploy-a-kafka-cluster}

1. Create the Kafka cluster using the KafkaCluster custom resource. You can find various examples for the custom resource in the [{{< kafka-operator >}} repository](https://github.com/banzaicloud/koperator/tree/{{< param "versionnumbers-sdm.koperatorCurrentversion" >}}/config/samples).

    {{< include-headless "warning-listener-protocol.md" "supertubes/kafka-operator" >}}

    - To create a sample Kafka cluster that allows unencrypted client connections, run the following command:

    ```bash
    kubectl create \
    -n kafka \
    -f https://raw.githubusercontent.com/banzaicloud/koperator/{{< param "versionnumbers-sdm.koperatorCurrentversion" >}}/config/samples/simplekafkacluster.yaml
    ```

    - To create a sample Kafka cluster that allows TLS-encrypted client connections, run the following command. For details on the configuration parameters related to SSL, see {{% xref "/docs/supertubes/kafka-operator/ssl.md#enable-ssl" %}}.

    ```bash
    kubectl create \
    -n kafka \
    -f https://raw.githubusercontent.com/banzaicloud/koperator/{{< param "versionnumbers-sdm.koperatorCurrentversion" >}}/config/samples/simplekafkacluster_ssl.yaml
    ```

    Expected output:

    ```bash
    kafkacluster.kafka.banzaicloud.io/kafka created
    ```
1. Wait and verify that the Kafka cluster resources have been deployed and are in running state.

    ```bash
    kubectl -n kafka get kafkaclusters.kafka.banzaicloud.io kafka --watch
    ```

    Expected output:

    ```bash
    NAME    CLUSTER STATE        CLUSTER ALERT COUNT   LAST SUCCESSFUL UPGRADE   UPGRADE ERROR COUNT   AGE
    kafka   ClusterReconciling   0                                               0                     5s
    kafka   ClusterReconciling   0                                               0                     7s
    kafka   ClusterReconciling   0                                               0                     8s
    kafka   ClusterReconciling   0                                               0                     9s
    kafka   ClusterReconciling   0                                               0                     2m17s
    kafka   ClusterReconciling   0                                               0                     3m11s
    kafka   ClusterReconciling   0                                               0                     3m27s
    kafka   ClusterReconciling   0                                               0                     3m29s
    kafka   ClusterReconciling   0                                               0                     3m31s
    kafka   ClusterReconciling   0                                               0                     3m32s
    kafka   ClusterReconciling   0                                               0                     3m32s
    kafka   ClusterRunning       0                                               0                     3m32s
    kafka   ClusterReconciling   0                                               0                     3m32s
    kafka   ClusterRunning       0                                               0                     3m34s
    kafka   ClusterReconciling   0                                               0                     4m23s
    kafka   ClusterRunning       0                                               0                     4m25s
    kafka   ClusterReconciling   0                                               0                     4m25s
    kafka   ClusterRunning       0                                               0                     4m27s
    kafka   ClusterRunning       0                                               0                     4m37s
    kafka   ClusterReconciling   0                                               0                     4m37s
    kafka   ClusterRunning       0                                               0                     4m39s
    ```

    ```bash
    kubectl get pods -n kafka
    ```

    Expected output:

    ```bash
    kafka-0-9brj4                              1/1     Running   0          94s
    kafka-1-c2spf                              1/1     Running   0          93s
    kafka-2-p6sg2                              1/1     Running   0          92s
    kafka-cruisecontrol-776f49fdbb-rjhp8       1/1     Running   0          51s
    kafka-operator-operator-7d47f65d86-2mx6b   2/2     Running   0          13m
    ```

1. If prometheus-operator is deployed, create a Prometheus instance and corresponding ServiceMonitors for {{< kafka-operator >}}.

    ```bash
    kubectl create \
    -n kafka \
    -f https://raw.githubusercontent.com/banzaicloud/koperator/{{< param "versionnumbers-sdm.koperatorCurrentversion" >}}/config/samples/kafkacluster-prometheus.yaml
    ```

    Expected output:

    ```bash
    clusterrole.rbac.authorization.k8s.io/prometheus created
    clusterrolebinding.rbac.authorization.k8s.io/prometheus created
    prometheus.monitoring.coreos.com/kafka-prometheus created
    prometheusrule.monitoring.coreos.com/kafka-alerts created
    serviceaccount/prometheus created
    servicemonitor.monitoring.coreos.com/cruisecontrol-servicemonitor created
    servicemonitor.monitoring.coreos.com/kafka-servicemonitor created
    ```

1. Wait and verify that the Kafka cluster Prometheus instance has been deployed and is in running state.

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
    prometheus-kafka-prometheus-0             2/2     Running   0          16m
    ```

## Test your deployment {#test-your-deployment}

- For a simple test, see [Test provisioned Kafka Cluster](../test/).
- For a more in-depth view at using SSL and the `KafkaUser` CRD, see [Securing Kafka With SSL](../ssl/).
- To create topics via with the `KafkaTopic` CRD, see [Provisioning Kafka Topics](../topics/).
