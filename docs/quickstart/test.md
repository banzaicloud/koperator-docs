---
title: Test provisioned Kafka Cluster
shorttitle: Test your cluster
weight: 100
---

## Create Topic

Topic creation by default is enabled in Kafka, but if it is configured otherwise, you'll need to create a topic first.

- You can use the `KafkaTopic` CRD to create a topic called **my-topic** like this:

    {{< include-code "create-topic.sample" "bash" >}}

    > Note: The previous command will fail if the cluster has not finished provisioning.

- To create a sample topic from the CLI you can run the following:

    ```bash
    kubectl -n kafka run kafka-topics -it --image=banzaicloud/kafka:2.13-2.4.0 --rm=true --restart=Never -- /opt/kafka/bin/kafka-topics.sh --zookeeper zookeeper-client.zookeeper:2181 --topic my-topic --create --partitions 1 --replication-factor 1
    ```

After you have created a topic, produce and consume some messages:

- [Send and receive messages without SSL within a cluster](#internal-nossl)
- [Send and receive messages with SSL within a cluster](#internal-ssl)

## Send and receive messages without SSL within a cluster {#internal-nossl}

You can use the following commands to send and receive messages within a Kubernetes cluster when SSL encryption is disabled for Kafka.

- Produce messages:

    ```bash
    kubectl -n kafka run kafka-producer -it --image=banzaicloud/kafka:2.13-2.4.0 --rm=true --restart=Never -- /opt/kafka/bin/kafka-console-producer.sh --bootstrap-server kafka-headless:29092 --topic my-topic
    ```

    And type some test messages.

- Consume messages:

    ```bash
    kubectl -n kafka run kafka-consumer -it --image=banzaicloud/kafka:2.13-2.4.0 --rm=true --restart=Never -- /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server kafka-headless:29092 --topic my-topic --from-beginning
    ```

    You should see the messages you have created.

## Send and receive messages with SSL within a cluster {#internal-ssl}

You can use the following procedure to send and receive messages within a Kubernetes cluster [when SSL encryption is enabled for Kafka]({{< relref "/docs/supertubes/kafka-operator/ssl.md#enable-ssl" >}}). To test a Kafka instance secured by SSL we recommend using [Kafkacat](https://github.com/edenhill/kafkacat).

> To use the java client instead of Kafkacat, generate the proper truststore and keystore using the [official docs](https://kafka.apache.org/documentation/#security_ssl).

1. Create a Kafka user. The client will use this user account to access Kafka. You can use the KafkaUser custom resource to customize the access rights as needed. For example:

    {{< include-code "create-kafkauser.sample" "bash" >}}

1. To use Kafka inside the cluster, create a Pod which contains `Kafkacat`. Create a `kafka-test` pod in the `kafka` namespace. Note that the value of the **secretName** parameter must be the same as you used when creating the KafkaUser resource, for example, example-kafkauser-secret.

    {{< include-code "kafkacat-ssl.sample" "bash" >}}

1. Wait until the pod is created, then exec into the container:

    ```bash
    kubectl exec -it -n kafka kafka-test -- sh
    ```

1. Run the following command to check that you can connect to the brokers.

    ```bash
    kafkacat -L -b kafka-headless:29092 -X security.protocol=SSL -X ssl.key.location=/ssl/certs/tls.key -X ssl.certificate.location=/ssl/certs/tls.crt -X ssl.ca.location=/ssl/certs/ca.crt
    ```

    The first line of the output should indicate that the communication is encrypted, for example:

    ```text
    Metadata for all topics (from broker -1: ssl://kafka-headless:29092/bootstrap):
    ```

1. Produce some test messages. Run:

    ```bash
    kafkacat -P -b kafka-headless:29092 -t my-topic \
    -X security.protocol=SSL \
    -X ssl.key.location=/ssl/certs/tls.key \
    -X ssl.certificate.location=/ssl/certs/tls.crt \
    -X ssl.ca.location=/ssl/certs/ca.crt
    ```

    And type some test messages.

1. Consume some messages.
    The following command will use the certificate provisioned with the cluster to connect to Kafka. If you'd like to create and use a different user, create a `KafkaUser` CR, for details, see the [SSL documentation](../ssl/).

    ```bash
    kafkacat -C -b kafka-headless:29092 -t my-topic \
    -X security.protocol=SSL \
    -X ssl.key.location=/ssl/certs/tls.key \
    -X ssl.certificate.location=/ssl/certs/tls.crt \
    -X ssl.ca.location=/ssl/certs/ca.crt
    ```

    You should see the messages you have created.

## Send and receive messages outside a cluster

### Prerequisites {#external-prerequisites}

1. Producers and consumers that are not in the same Kubernetes cluster can access the Kafka cluster only if an [external listener]({{< relref "/docs/supertubes/kafka-operator/external-listener/index.md" >}}) is configured in your KafkaCluster CR. Check that the **listenersConfig.externalListeners** section exists in the KafkaCluster CR.
1. Obtain the external address and port number of the cluster by running the following commands.

    <!-- FIXME How is this different if we use nodeport for the external listener? -->
    - If the external listener uses a LoadBalancer:

        ```bash
        export SERVICE_IP=$(kubectl get svc --namespace kafka -o jsonpath="{.status.loadBalancer.ingress[0].hostname}" envoy-loadbalancer-external-kafka); echo $SERVICE_IP

        export SERVICE_PORTS=($(kubectl get svc --namespace kafka -o jsonpath="{.spec.ports[*].port}" envoy-loadbalancer-external-kafka)); echo ${SERVICE_PORTS[@]}

        # depending on the shell you are using, arrays may be indexed starting from 0 or 1
        export SERVICE_PORT=${SERVICE_PORTS[@]:0:1}; echo $SERVICE_PORT
        ```

1. If the external listener of your Kafka cluster accepts encrypted connections, proceed to [SSL enabled](#external-ssl). Otherwise, proceed to [SSL disabled](#external-nossl).

### SSL disabled {#external-nossl}

1. Produce some test messages on the the external client.

    - If you have [Kafkacat](https://github.com/edenhill/kafkacat) installed, run:

        ```bash
        kafkacat -P -b $SERVICE_IP:$SERVICE_PORT -t my-topic
        ```

    - If you have the Java Kafka client installed, run:

        ```bash
        kafka-console-producer.sh --bootstrap-server $SERVICE_IP:$SERVICE_PORT --topic my-topic
        ```

    And type some test messages.

1. Consume some messages.

    - If you have [Kafkacat](https://github.com/edenhill/kafkacat) installed, run:

        ```bash
        kafkacat -C -b $SERVICE_IP:$SERVICE_PORT -t my-topic
        ```

    - If you have the Java Kafka client installed, run:

        ```bash
        kafka-console-consumer.sh --bootstrap-server $SERVICE_IP:$SERVICE_PORT --topic my-topic --from-beginning
        ```

    You should see the messages you have created.

### SSL enabled {#external-ssl}

You can use the following procedure to send and receive messages from an external host that is outside a Kubernetes cluster when SSL encryption is enabled for Kafka. To test a Kafka instance secured by SSL we recommend using [Kafkacat](https://github.com/edenhill/kafkacat).

> To use the java client instead of Kafkacat, generate the proper truststore and keystore using the [official docs](https://kafka.apache.org/documentation/#security_ssl).

1. Install Kafkacat.

    - __MacOS__:

        ```bash
        brew install kafkacat
        ```

    - __Ubuntu__:

        ```bash
        apt-get update
        apt-get install kafkacat
        ```

1. Connect to the Kubernetes cluster that runs your Kafka deployment.

1. Create a Kafka user. The client will use this user account to access Kafka. You can use the KafkaUser custom resource to customize the access rights as needed. For example:

    {{< include-code "create-kafkauser.sample" "bash" >}}

1. Download the certificate and the key of the user, and the CA certificate used to verify the certificate of the Kafka server. These are available in the Kubernetes Secret created for the KafkaUser.

    ```bash
    kubectl get secrets -n kafka <name-of-the-user-secret> -o jsonpath="{['data']['tls\.crt']}" | base64 -D > client.crt.pem
    kubectl get secrets -n kafka <name-of-the-user-secret> -o jsonpath="{['data']['tls\.key']}" | base64 -D > client.key.pem
    kubectl get secrets -n kafka <name-of-the-user-secret> -o jsonpath="{['data']['ca\.crt']}" | base64 -D > ca.crt.pem
    ```

1. Copy the downloaded certificates to a location that is accessible to the external host.

1. If you haven't done so already, [obtain the external address and port number of the cluster](#external-prerequisites).

1. Produce some test messages on the host that is outside your cluster.

    ```bash
    kafkacat -b $SERVICE_IP:$SERVICE_PORT -P -X security.protocol=SSL \
    -X ssl.key.location=client.key.pem \
    -X ssl.certificate.location=client.crt.pem \
    -X ssl.ca.location=ca.crt.pem \
    -t my-topic
    ```

    And type some test messages.

1. Consume some messages.

    ```bash
    kafkacat -b $SERVICE_IP:$SERVICE_PORT -C -X security.protocol=SSL \
    -X ssl.key.location=client.key.pem \
    -X ssl.certificate.location=client.crt.pem \
    -X ssl.ca.location=ca.crt.pem \
    -t my-topic
    ```

    You should see the messages you have created.