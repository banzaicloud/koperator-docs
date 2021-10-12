---
title: Securing Kafka With SSL
shorttitle: SSL
weight: 300
---

The {{< kafka-operator >}} makes securing your Apache Kafka cluster with SSL simple.

## Enable SSL encryption in Apache Kafka {#enable-ssl}

To create an Apache Kafka cluster with SSL encryption enabled, you must enable SSL encryption and configure the secrets in the **listenersConfig** section of your **KafkaCluster** Custom Resource. You can provide your own certificates, or instruct the operator to create them for you from your cluster configuration.

{{< include-headless "warning-listener-protocol.md" "kafka-operator" >}}

The following example enables SSL and automatically generates the certificates:

{{< include-code "enable-ssl.sample" "yaml" >}}

If `sslSecrets.create` is `false`, the operator will look for the secret at `sslSecrets.tlsSecretName` and expect these values:

| Key          | Value              |
|:------------:|:-------------------|
| `caCert`     | The CA certificate |
| `caKey`      | The CA private key |
| `clientCert` | A client certificate (this will be used by cruise control and the operator for kafka operations) |
| `clientKey`  | The private key for `clientCert` |
| `peerCert`   | The certificate for the kafka brokers |
| `peerKey`    | The private key for the kafka brokers |

## Using Kafka ACLs with SSL

> Note: {{< kafka-operator >}} provides only basic ACL support. For a more complete and robust solution, consider using the [Streaming Data Manager](https://banzaicloud.com/products/supertubes/) product.
> {{< include-headless "kafka-operator-supertubes-intro.md" >}}

If you choose not to enable ACLs for your Apache Kafka cluster, you may still use the `KafkaUser` resource to create new certificates for your applications.
You can leave the `topicGrants` out as they will not have any effect.

1. To enable ACL support for your Apache Kafka cluster, pass the following configurations along with your `brokerConfig`:

    ```yaml
    authorizer.class.name=kafka.security.authorizer.AclAuthorizer
    allow.everyone.if.no.acl.found=false
    ```

1. The operator will ensure that cruise control and itself can still access the cluster, however, to create new clients
you will need to generate new certificates signed by the CA, and ensure ACLs on the topic. The operator can automate this process for you using the `KafkaUser` CRD.
    For example, to create a new producer for the topic `test-topic` against the KafkaCluster `kafka`, apply the following configuration:

    ```bash
    cat << EOF | kubectl apply -n kafka -f -
    apiVersion: kafka.banzaicloud.io/v1alpha1
    kind: KafkaUser
    metadata:
      name: example-producer
      namespace: kafka
    spec:
      clusterRef:
        name: kafka
      secretName: example-producer-secret
      topicGrants:
        - topicName: test-topic
          accessType: write
    EOF
    ```

    This will create a user and store its credentials in the secret `example-producer-secret`. The secret contains these fields:

    | Key          | Value                |
    |:------------:|:---------------------|
    | `ca.crt`     | The CA certificate   |
    | `tls.crt`    | The user certificate |
    | `tls.key`    | The user private key |

1. You can then mount these secrets to your pod. Alternatively, you can write them to your local machine by running:

    ```bash
    kubectl get secret example-producer-secret -o jsonpath="{['data']['ca\.crt']}" | base64 -d > ca.crt
    kubectl get secret example-producer-secret -o jsonpath="{['data']['tls\.crt']}" | base64 -d > tls.crt
    kubectl get secret example-producer-secret -o jsonpath="{['data']['tls\.key']}" | base64 -d > tls.key
    ```

1. To create a consumer for the topic, run this command:

    ```bash
    cat << EOF | kubectl apply -n kafka -f -
    apiVersion: kafka.banzaicloud.io/v1alpha1
    kind: KafkaUser
    metadata:
      name: example-consumer
      namespace: kafka
    spec:
      clusterRef:
        name: kafka
      secretName: example-consumer-secret
      includeJKS: true
      topicGrants:
        - topicName: test-topic
          accessType: read
    EOF
    ```

1. The operator can also include a Java keystore format (JKS) with your user secret if you'd like. Add `includeJKS: true` to the `spec` like shown above, and then the user-secret will gain these additional fields:

    | Key                     | Value                |
    |:-----------------------:|:---------------------|
    | `tls.jks`               | The java keystore containing both the user keys and the CA (use this for your keystore AND truststore) |
    | `pass.txt`              | The password to decrypt the JKS (this will be randomly generated) |
