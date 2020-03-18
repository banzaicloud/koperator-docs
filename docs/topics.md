---
title: Provisioning Kafka Topics
shorttitle: Kafka topics
weight: 200
---

You can create Kafka topics either:

- directly against the cluster with command line utilities, or
- via the `KafkaTopic` CRD.

Below is an example `KafkaTopic` CR.

```yaml
# topic.yaml
---
apiVersion: kafka.banzaicloud.io/v1alpha1
kind: KafkaTopic
metadata:
  name: example-topic
  namespace: kafka
spec:
  clusterRef:
    name: kafka
  name: example-topic
  partitions: 3
  replicationFactor: 2
  config:
    # For a full list of configuration options, refer to the official documentation.
    # https://kafka.apache.org/documentation/#topicconfigs
    "retention.ms": "604800000"
    "cleanup.policy": "delete"
```

You can apply the above topic with kubectl:

```shell
banzai@cloud:~$ kubectl apply -n kafka -f topic.yaml

kafkatopic.kafka.banzaicloud.io/example-topic created
```

If you want to update the configuration of the topic after it's been created, you can either:

- edit the manifest and run `kubectl apply` again, or 
- run `kubectl edit -n kafka kafkatopic example-topic` and then update the configuration in the editor that gets spawned.

You can increase the partition count for a topic the same way, or by running the following one-liner using `patch`:

```shell
banzai@cloud:~$ kubectl patch -n kafka kafkatopic example-topic --patch '{"spec": {"partitions": 5}}' --type=merge

kafkatopic.kafka.banzaicloud.io/example-topic patched
```

> Note: Topics created by the Kafka operator are not enforced in any way. From the Kubernetes perspective, Kafka Topics are external resources.
