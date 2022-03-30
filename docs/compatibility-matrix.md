---
title: Supported versions and compatibility matrix
shorttitle: Supported versions
weight: 770
---

This page shows you the list of supported {{< kafka-operator >}} versions, and the versions of other components they are compatible with.

## Compatibility matrix

|Operator Version|Apache Kafka Version|JMX Exporter Version|Cruise Control Version|Istio Operator Version|Example cluster CR|Maintained|
|-------|------|----------------|-------|----|---|-|
|v0.18.3|2.6.2+|0.15.0|2.5.37|1.10|[link](https://github.com/banzaicloud/koperator/blob/v0.18.3/config/samples/simplekafkacluster.yaml)|+|
|v0.19.0|2.6.2+|0.15.0|2.5.68|1.10|[link](https://github.com/banzaicloud/koperator/blob/v0.19.0/config/samples/simplekafkacluster.yaml)|+|
|v0.20.0|2.6.2+|0.15.0|2.5.68|1.10|[link](https://github.com/banzaicloud/koperator/blob/v0.20.0/config/samples/simplekafkacluster.yaml)|+|
|v0.20.2|2.6.2+|0.16.1|2.5.80|1.10|[link](https://github.com/banzaicloud/koperator/blob/v0.20.2/config/samples/simplekafkacluster.yaml)|+|
|v0.21.0|2.6.2+|0.16.1|2.5.86|1.11|[link](https://github.com/banzaicloud/koperator/blob/v0.21.0/config/samples/simplekafkacluster.yaml)|+|

## Available {{< kafka-operator >}} images

|Image|Go version|
|-|-|
|ghcr.io/banzaicloud/kafka-operator:v0.17.0|1.16|
|ghcr.io/banzaicloud/kafka-operator:v0.18.3|1.16|
|ghcr.io/banzaicloud/kafka-operator:v0.19.0 |1.16|
|ghcr.io/banzaicloud/kafka-operator:v0.20.2 |1.17|
|ghcr.io/banzaicloud/kafka-operator:v0.21.0 |1.17|

## Available Apache Kafka images

|Image|Java version|
|-|-|
|ghcr.io/banzaicloud/kafka:2.13-2.6.2-bzc.1|11|
|ghcr.io/banzaicloud/kafka:2.13-2.7.0-bzc.1|11|
|ghcr.io/banzaicloud/kafka:2.13-2.7.0-bzc.2|11|
|ghcr.io/banzaicloud/kafka:2.13-2.8.0|11|
|ghcr.io/banzaicloud/kafka:2.13-2.8.1|11|

## Available JMX Exporter images

|Image|Java version|
|-|-|
|ghcr.io/banzaicloud/jmx-javaagent:0.14.0|11|
|ghcr.io/banzaicloud/jmx-javaagent:0.15.0|11|
|ghcr.io/banzaicloud/jmx-javaagent:0.16.1|11|

## Available Cruise Control images

|Image|Java version|
|-|-|
|ghcr.io/banzaicloud/cruise-control:2.5.23|11|
|ghcr.io/banzaicloud/cruise-control:2.5.28|11|
|ghcr.io/banzaicloud/cruise-control:2.5.34|11|
|ghcr.io/banzaicloud/cruise-control:2.5.37|11|
|ghcr.io/banzaicloud/cruise-control:2.5.43|11|
|ghcr.io/banzaicloud/cruise-control:2.5.53|11|
|ghcr.io/banzaicloud/cruise-control:2.5.68|11|
|ghcr.io/banzaicloud/cruise-control:2.5.80|11|
