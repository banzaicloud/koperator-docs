---
title: Common types
weight: 200
generated_file: true
---

## KafkaVersion

KafkaVersion type describes the kafka version and docker version

### version (string, optional) {#kafkaversion-version}

Version holds the current version of the broker in semver format<br>

Default: -

### image (string, optional) {#kafkaversion-image}

Image specifies the current docker image of the broker<br>

Default: -


## GracefulActionState

GracefulActionState holds information about GracefulAction State

### errorMessage (string, required) {#gracefulactionstate-errormessage}

ErrorMessage holds the information what happened with CC<br>

Default: -

### cruiseControlTaskId (string, optional) {#gracefulactionstate-cruisecontroltaskid}

CruiseControlTaskId holds info about the task id ran by CC<br>

Default: -

### TaskStarted (string, optional) {#gracefulactionstate-taskstarted}

TaskStarted hold the time when the execution started<br>

Default: -

### cruiseControlState (CruiseControlState, required) {#gracefulactionstate-cruisecontrolstate}

CruiseControlState holds the information about CC state<br>

Default: -

### volumeStates (map[string]VolumeState, optional) {#gracefulactionstate-volumestates}

VolumeStates holds the information about the CC disk rebalance states and tasks<br>

Default: -


## VolumeState

### errorMessage (string, required) {#volumestate-errormessage}

ErrorMessage holds the information what happened with CC disk rebalance<br>

Default: -

### cruiseControlTaskId (string, optional) {#volumestate-cruisecontroltaskid}

CruiseControlTaskId holds info about the task id ran by CC<br>

Default: -

### TaskStarted (string, optional) {#volumestate-taskstarted}

TaskStarted hold the time when the execution started<br>

Default: -

### cruiseControlVolumeState (CruiseControlVolumeState, required) {#volumestate-cruisecontrolvolumestate}

CruiseControlVolumeState holds the information about the CC disk rebalance state<br>

Default: -


## BrokerState

BrokerState holds information about broker state

### rackAwarenessState (RackAwarenessState, required) {#brokerstate-rackawarenessstate}

RackAwarenessState holds info about rack awareness status<br>

Default: -

### gracefulActionState (GracefulActionState, required) {#brokerstate-gracefulactionstate}

GracefulActionState holds info about cc action status<br>

Default: -

### configurationState (ConfigurationState, required) {#brokerstate-configurationstate}

ConfigurationState holds info about the config<br>

Default: -

### perBrokerConfigurationState (PerBrokerConfigurationState, required) {#brokerstate-perbrokerconfigurationstate}

PerBrokerConfigurationState holds info about the per-broker (dynamically updatable) config<br>

Default: -

### externalListenerConfigNames (ExternalListenerConfigNames, optional) {#brokerstate-externallistenerconfignames}

ExternalListenerConfigNames holds info about what listener config is in use with the broker<br>

Default: -

### version (string, optional) {#brokerstate-version}

Version holds the current version of the broker in semver format<br>

Default: -

### image (string, optional) {#brokerstate-image}

Image specifies the current docker image of the broker<br>

Default: -


