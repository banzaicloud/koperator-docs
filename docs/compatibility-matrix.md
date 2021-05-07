---
title: Supported versions and compatibility matrix
shorttitle: Supported versions
weight: 770
---

This page shows you the list of supported Kafka operator versions, and the versions of other components they are compatible with.

## Compatibility matrix

|Operator Version|Apache Kafka Version|JMX Exporter Version|Cruise Control Version|Istio Operator Version|Example cluster CR|Maintained|
|-------|------|----------------|-------|----|---|-|
|v0.14.0|2.5.0+|0.14.0|2.5.23|1.5|[link](https://github.com/banzaicloud/kafka-operator/blob/v0.14.0/config/samples/simplekafkacluster.yaml)|+|
|v0.15.0|2.5.0+|0.14.0|2.5.28|1.8|[link](https://github.com/banzaicloud/kafka-operator/blob/v0.15.1/config/samples/simplekafkacluster.yaml)|+|
|v0.16.0|2.5.0+|0.15.0|2.5.37|1.9|[link](https://github.com/banzaicloud/kafka-operator/blob/v0.16.1/config/samples/simplekafkacluster.yaml)|+|

## Available Kafka operator images

|Image|Go version|
|-|-|
|ghcr.io/banzaicloud/kafka-operator:v0.14.0|1.14|
|ghcr.io/banzaicloud/kafka-operator:v0.15.0|1.15|
|ghcr.io/banzaicloud/kafka-operator:v0.15.1|1.15|
|ghcr.io/banzaicloud/kafka-operator:v0.16.0|1.15|
|ghcr.io/banzaicloud/kafka-operator:v0.16.1|1.15|

## Available Apache Kafka images

|Image|Java version|
|-|-|
|banzaicloud/kafka:2.13-2.5.0-bzc.1|11|
|banzaicloud/kafka:2.13-2.5.1-bzc.1|11|
|ghcr.io/banzaicloud/kafka:2.13-2.6.0-bzc.1|11|
|ghcr.io/banzaicloud/kafka:2.13-2.6.1-bzc.1|11|
|ghcr.io/banzaicloud/kafka:2.13-2.7.0-bzc.1|11|
|ghcr.io/banzaicloud/kafka:2.13-2.7.0-bzc.2|11|

## Available JMX Exporter images

|Image|Java version|
|-|-|
|ghcr.io/banzaicloud/jmx-javaagent:0.14.0|11|
|ghcr.io/banzaicloud/jmx-javaagent:0.15.0|11|

## Available Cruise Control images

|Image|Java version|
|-|-|
|ghcr.io/banzaicloud/cruise-control:2.5.23|11|
|ghcr.io/banzaicloud/cruise-control:2.5.28|11|
|ghcr.io/banzaicloud/cruise-control:2.5.34|11|
|ghcr.io/banzaicloud/cruise-control:2.5.37|11|
|ghcr.io/banzaicloud/cruise-control:2.5.43|11|
