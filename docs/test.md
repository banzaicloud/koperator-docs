---
title: Test provisioned Kafka Cluster
shorttitle: Test your cluster
weight: 100
---

## Create Topic

Topic creation by default is enabled in Kafka, but if it is configured otherwise, you'll need to create a topic first.

- You can use the `KafkaTopic` CRD to make a topic like this:

    {{< include-code "create-topic.sample" "bash" >}}

    > Note: The previous command will fail if the cluster has not finished provisioning.

- To create a sample topic from the CLI you can run the following:

    ```bash
    kubectl -n kafka run kafka-topics -it --image=banzaicloud/kafka:2.13-2.4.0 --rm=true --restart=Never -- /opt/kafka/bin/kafka-topics.sh --zookeeper zookeeper-client.zookeeper:2181 --topic my-topic --create --partitions 1 --replication-factor 1
    ```

## Send and receive messages without SSL within a cluster

You can use the following commands to send and receive messages within a Kubernetes cluster when SSL encryption is disabled for Kafka.

- Produce messages:

    ```bash
    kubectl -n kafka run kafka-producer -it --image=banzaicloud/kafka:2.13-2.4.0 --rm=true --restart=Never -- /opt/kafka/bin/kafka-console-producer.sh --broker-list kafka-headless:29092 --topic my-topic
    ```

    And type some test messages.

- Consume messages:

    ```bash
    kubectl -n kafka run kafka-consumer -it --image=banzaicloud/kafka:2.13-2.4.0 --rm=true --restart=Never -- /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server kafka-headless:29092 --topic my-topic --from-beginning
    ```

    You should see the messages you have created.

## Send and receive messages with SSL within a cluster

You can use the following procedure to send and receive messages within a Kubernetes cluster when SSL encryption is enabled for Kafka. To test a Kafka instance secured by SSL we recommend using [Kafkacat](https://github.com/edenhill/kafkacat).

> To use the java client instead of Kafkacat, generate the proper truststore and keystore using the [official docs](https://kafka.apache.org/documentation/#security_ssl).

1. To use Kafka inside the cluster, create a Pod which contains `Kafkacat`.
1. Create a `kafka-test` pod in the `kafka` namespace.

    ```bash
    kubectl create -n kafka -f - <<EOF
    apiVersion: v1
    kind: Pod
    metadata:
      name: kafka-test
    spec:
      containers:
      - name: kafka-test
        image: solsson/kafkacat
        # Just spin & wait forever
        command: [ "/bin/sh", "-c", "--" ]
        args: [ "while true; do sleep 3000; done;" ]
        volumeMounts:
        - name: sslcerts
          mountPath: "/ssl/certs"
      volumes:
      - name: sslcerts
        secret:
          secretName: kafka-operator-serving-cert
    EOF
    ```

1. Exec into the container:

    ```bash
    kubectl exec -it -n kafka kafka-test bash
    ```

1. Produce some test messages.

    ```bash
    kafkacat -P -b kafka-headless:29092 -t my-topic \
    -X security.protocol=SSL \
    -X ssl.key.location=/ssl/certs/tls.key \
    -X ssl.certificate.location=/ssl/certs/tls.crt \
    -X ssl.ca.location=/ssl/certs/ca.crt
    ```

1. Consume some messages.
    The following command will use the certificate provisioned with the cluster to connect to Kafka. If you'd like to create and use a different user, create a `KafkaUser` CR, for details, see the [SSL documentation](../ssl/).

    ```bash
    kafkacat -C -b kafka-headless:29092 -t my-topic \
    -X security.protocol=SSL \
    -X ssl.key.location=/ssl/certs/tls.key \
    -X ssl.certificate.location=/ssl/certs/tls.crt \
    -X ssl.ca.location=/ssl/certs/ca.crt
    ```

## Send and receive messages outside a cluster

Obtain the LoadBalancer address first by running the following command.

```bash
export SERVICE_IP=$(kubectl get svc --namespace kafka -o jsonpath="{.status.loadBalancer.ingress[0].ip}" envoy-loadbalancer)

echo $SERVICE_IP

export SERVICE_PORTS=($(kubectl get svc --namespace kafka -o jsonpath="{.spec.ports[*].port}" envoy-loadbalancer))

echo ${SERVICE_PORTS[@]}

# depending on the shell of your choice, arrays may be indexed starting from 0 or 1
export SERVICE_PORT=${SERVICE_PORTS[@]:0:1}

echo $SERVICE_PORT
```

### SSL Disabled

- Produce messages:

    ```bash
    kafka-console-producer.sh --broker-list $SERVICE_IP:$SERVICE_PORT --topic my-topic
    ```

- Consume messages

    ```bash
    kafka-console-consumer.sh --bootstrap-server $SERVICE_IP:$SERVICE_PORT --topic my-topic --from-beginning
    ```

### SSL Enabled

You can use the following procedure to send and receive messages outside a Kubernetes cluster when SSL encryption is enabled for Kafka. To test a Kafka instance secured by SSL we recommend using [Kafkacat](https://github.com/edenhill/kafkacat).

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

1. Extract secrets from the given Kubernetes Secret:

    ```bash
    kubectl get secrets -n kafka kafka-operator-serving-cert -o jsonpath="{['data']['\tls.crt']}" | base64 -D > client.crt.pem
    kubectl get secrets -n kafka kafka-operator-serving-cert -o jsonpath="{['data']['\tls.key']}" | base64 -D > client.key.pem
    kubectl get secrets -n kafka kafka-operator-serving-cert -o jsonpath="{['data']['\ca.crt']}" | base64 -D > ca.crt.pem
    ```

1. Produce some test messages.

    ```bash
    kafkacat -b $SERVICE_IP:$SERVICE_PORT -P -X security.protocol=SSL \
    -X ssl.key.location=client.key.pem \
    -X ssl.certificate.location=client.crt.pem \
    -X ssl.ca.location=ca.crt.pem \
    -t my-topic
    ```

1. Consume some messages.

    ```bash
    kafkacat -b $SERVICE_IP:$SERVICE_PORT -C -X security.protocol=SSL \
    -X ssl.key.location=client.key.pem \
    -X ssl.certificate.location=client.crt.pem \
    -X ssl.ca.location=ca.crt.pem \
    -t my-topic
    ```
