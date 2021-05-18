---
title: KafkaClusterSpec
weight: 200
generated_file: true
---

## KafkaClusterSpec

KafkaClusterSpec defines the desired state of KafkaCluster.

### headlessServiceEnabled (bool, required) {#kafkaclusterspec-headlessserviceenabled}

Specifies if the cluster uses headlessService for Kafka, or individual services using service/broker.<br>Using individual services can be useful when operating in a service mesh or when using ServiceMonitors.<br>

Default: -

### listenersConfig (ListenersConfig, required) {#kafkaclusterspec-listenersconfig}

Default: -

### zkAddresses ([]string, required) {#kafkaclusterspec-zkaddresses}

ZKAddresses specifies the zookeeper addresses where the Kafka should store it's metadata.<br>Use the host and port of the ZooKeeper server in the hostname:port format, for example, `zookeeper-client.zookeeper:2181`<br>

Default: -

### zkPath (string, optional) {#kafkaclusterspec-zkpath}

ZKPath specifies the ZooKeeper chroot path as part<br>of the ZooKeeper connection string where the Kafka related metadatas should be placed in the global ZooKeeper namespace, for example, "/kafka". Can be left blank.<br><br>

Default:  "/"

### rackAwareness (*RackAwareness, optional) {#kafkaclusterspec-rackawareness}

Configures Kafka's rack awareness feature. For details, see [RackAwareness](#rackawareness).<br>

Default: -

### clusterImage (string, optional) {#kafkaclusterspec-clusterimage}

Specifies the whole kafkacluster image in one place, for example, "ghcr.io/banzaicloud/kafka:2.13-2.7.0-bzc.2"<br>

Default: -

### readOnlyConfig (string, optional) {#kafkaclusterspec-readonlyconfig}

Specifies the read-only type Kafka configuration for the entire cluster. This is merged with the broker-specified readOnly configurations, so it can be overwritten per broker.<br>

Default: -

### clusterWideConfig (string, optional) {#kafkaclusterspec-clusterwideconfig}

Specifies the cluster-wide Kafka configuration. Note that you can override it per-broker. For example: "background.threads=10"<br>

Default: -

### brokerConfigGroups (map[string]BrokerConfig, optional) {#kafkaclusterspec-brokerconfiggroups}

Specifies multiple broker configurations with a unique name.<br>

Default: -

### brokers ([]Broker, required) {#kafkaclusterspec-brokers}

Specifies the brokers in the cluster.<br>All Broker requires an image, a unique id, and storageConfigs settings. For details, see [Broker](#broker).<br>

Default: -

### disruptionBudget (DisruptionBudget, optional) {#kafkaclusterspec-disruptionbudget}

Defines the configuration for [PodDisruptionBudget](#disruptionbudget).<br>

Default: -

### rollingUpgradeConfig (RollingUpgradeConfig, required) {#kafkaclusterspec-rollingupgradeconfig}

Specifies the [rolling upgrade configuration](#rollingupgradeconfig) for the cluster<br>

Default: -

### ingressController (string, optional) {#kafkaclusterspec-ingresscontroller}

Specifies the ingress controller to use. Only envoy and istioingress are supported. Can be left blank.<br>

Default: -

### oneBrokerPerNode (bool, required) {#kafkaclusterspec-onebrokerpernode}

If true, OneBrokerPerNode ensures that each Kafka broker is placed on a different node, unless a custom<br>Affinity definition overrides this behavior. If there are not enough nodes to do that, newly started brokers stay in pending state.<br><br>If set to false, the operator tries to schedule the brokers to a unique node, but if there aren't enough nodes, new brokers are scheduled to a node where a broker is already running.<br>

Default: -

### propagateLabels (bool, optional) {#kafkaclusterspec-propagatelabels}

Default: -

### cruiseControlConfig (CruiseControlConfig, required) {#kafkaclusterspec-cruisecontrolconfig}

Describes the configuration related to Cruise Control. For details, see [CruiseControlConfig](#cruisecontrolconfig).<br>

Default: -

### envoyConfig (EnvoyConfig, optional) {#kafkaclusterspec-envoyconfig}

Defines the configuration for Envoy. For details, see [EnvoyConfig](#envoyconfig).<br>

Default: -

### monitoringConfig (MonitoringConfig, optional) {#kafkaclusterspec-monitoringconfig}

Defines the monitoring configuration for Kafka and Cruise Control. For details, see [MonitoringConfig](#monitoringconfig).<br>

Default: -

### vaultConfig (VaultConfig, optional) {#kafkaclusterspec-vaultconfig}

Defines the configuration for a vault PKI backend. For details, see [VaultConfig](#vaultconfig).<br>

Default: -

### alertManagerConfig (*AlertManagerConfig, optional) {#kafkaclusterspec-alertmanagerconfig}

Defines the configuration of [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/). For details, see [AlertManagerConfig](#alertmanagerconfig).<br>

Default: -

### istioIngressConfig (IstioIngressConfig, optional) {#kafkaclusterspec-istioingressconfig}

Defines the configuration of the Istio Ingress Controller. For details, see [IstioIngressConfig](#istioingressconfig).<br>

Default: -

### envs ([]corev1.EnvVar, optional) {#kafkaclusterspec-envs}

Envs defines environment variables for Kafka broker Pods.<br>Adding the "+" prefix to the name prepends the value to that environment variable instead of overwriting it.<br>Add the "+" suffix to append.<br>

Default: -

### kubernetesClusterDomain (string, optional) {#kafkaclusterspec-kubernetesclusterdomain}

Default: -


## KafkaClusterStatus

KafkaClusterStatus defines the observed state of KafkaCluster

### brokersState (map[string]BrokerState, optional) {#kafkaclusterstatus-brokersstate}

BrokerState holds information about the [state of the broker](../common_types/#brokerstate).<br>

Default: -

### cruiseControlTopicStatus (CruiseControlTopicStatus, optional) {#kafkaclusterstatus-cruisecontroltopicstatus}

Holds information about the CC topic status.<br>

Default: -

### state (ClusterState, required) {#kafkaclusterstatus-state}

Holds information about the cluster state.<br>

Default: -

### rollingUpgradeStatus (RollingUpgradeStatus, optional) {#kafkaclusterstatus-rollingupgradestatus}

The status of the [rolling upgrade](#rollingupgradestatus).<br>

Default: -

### alertCount (int, required) {#kafkaclusterstatus-alertcount}

Default: -

### listenerStatuses (ListenerStatuses, optional) {#kafkaclusterstatus-listenerstatuses}

[ListenerStatuses](#listenerstatuses) holds information about the statuses of the configured listeners<br>

Default: -


## RollingUpgradeStatus

RollingUpgradeStatus defines status of rolling upgrade

### lastSuccess (string, required) {#rollingupgradestatus-lastsuccess}

Default: -

### errorCount (int, required) {#rollingupgradestatus-errorcount}

Default: -


## RollingUpgradeConfig

RollingUpgradeConfig defines the desired config of the RollingUpgrade

### failureThreshold (int, required) {#rollingupgradeconfig-failurethreshold}

Default: -


## DisruptionBudget

DisruptionBudget defines the configuration for PodDisruptionBudget

### create (bool, optional) {#disruptionbudget-create}

If set to true, will create a podDisruptionBudget<br>+optional<br>

Default: -

### budget (string, optional) {#disruptionbudget-budget}

The budget to set for the PDB, can either be static number or a percentage<br>

Default: -


## Broker

Broker defines the broker basic configuration

### id (int32, required) {#broker-id}

Default: -

### brokerConfigGroup (string, optional) {#broker-brokerconfiggroup}

Default: -

### readOnlyConfig (string, optional) {#broker-readonlyconfig}

Default: -

### brokerConfig (*BrokerConfig, optional) {#broker-brokerconfig}

Default: -


## BrokerConfig

BrokerConfig defines the broker configuration

### image (string, optional) {#brokerconfig-image}

Default: -

### config (string, optional) {#brokerconfig-config}

Default: -

### storageConfigs ([]StorageConfig, optional) {#brokerconfig-storageconfigs}

Default: -

### serviceAccountName (string, optional) {#brokerconfig-serviceaccountname}

Default: -

### resourceRequirements (*corev1.ResourceRequirements, optional) {#brokerconfig-resourcerequirements}

Default: -

### imagePullSecrets ([]corev1.LocalObjectReference, optional) {#brokerconfig-imagepullsecrets}

Default: -

### nodeSelector (map[string]string, optional) {#brokerconfig-nodeselector}

Default: -

### tolerations ([]corev1.Toleration, optional) {#brokerconfig-tolerations}

Default: -

### kafkaHeapOpts (string, optional) {#brokerconfig-kafkaheapopts}

Default: -

### kafkaJvmPerfOpts (string, optional) {#brokerconfig-kafkajvmperfopts}

Default: -

### log4jConfig (string, optional) {#brokerconfig-log4jconfig}

Override for the default log4j configuration<br>

Default: -

### brokerAnnotations (map[string]string, optional) {#brokerconfig-brokerannotations}

Custom annotations for the broker pods - e.g.: Prometheus scraping annotations:<br>prometheus.io/scrape: "true"<br>prometheus.io/port: "9020"<br>

Default: -

### networkConfig (*NetworkConfig, optional) {#brokerconfig-networkconfig}

Network throughput information in kB/s used by Cruise Control to determine broker network capacity.<br>By default it is set to `125000` which means 1Gbit/s in network throughput.<br><br>

Default:  125000

### nodePortExternalIP (map[string]string, optional) {#brokerconfig-nodeportexternalip}

External listeners that use NodePort type service to expose the broker outside the Kubernetes clusterT and their<br>external IP to advertise Kafka broker external listener. The external IP value is ignored in case of external listeners that use LoadBalancer<br>type service to expose the broker outside the Kubernetes cluster. Also, when "hostnameOverride" field of the external listener is set<br>it will override the broker's external listener advertise address according to the description of the "hostnameOverride" field.<br>

Default: -

### affinity (*corev1.Affinity, optional) {#brokerconfig-affinity}

Any definition received through this field will override the default behavior of OneBrokerPerNode flag<br>and the operator supposes that the user is aware of how scheduling is done by kubernetes<br>Affinity could be set through brokerConfigGroups definitions and can be set for individual brokers as well<br>where letter setting will override the group setting<br><br>

Default:  OneBrokerPerNode

### podSecurityContext (*corev1.PodSecurityContext, optional) {#brokerconfig-podsecuritycontext}

Default: -

### securityContext (*corev1.SecurityContext, optional) {#brokerconfig-securitycontext}

SecurityContext allows to set security context for the kafka container<br>

Default: -

### brokerIngressMapping ([]string, optional) {#brokerconfig-brokeringressmapping}

BrokerIngressMapping allows to set specific ingress to a specific broker mappings.<br>If left empty, all broker will inherit the default one specified under external listeners config<br>Only used when ExternalListeners.Config is populated<br>

Default: -

### initContainers ([]corev1.Container, optional) {#brokerconfig-initcontainers}

InitContainers add extra initContainers to the Kafka broker pod<br>

Default: -

### volumes ([]corev1.Volume, optional) {#brokerconfig-volumes}

Volumes define some extra Kubernetes Volumes for the Kafka broker Pods.<br>

Default: -

### volumeMounts ([]corev1.VolumeMount, optional) {#brokerconfig-volumemounts}

VolumeMounts define some extra Kubernetes VolumeMounts for the Kafka broker Pods.<br>

Default: -

### envs ([]corev1.EnvVar, optional) {#brokerconfig-envs}

Envs defines environment variables for Kafka broker Pods.<br>Adding the "+" prefix to the name prepends the value to that environment variable instead of overwriting it.<br>Add the "+" suffix to append.<br>

Default: -


## NetworkConfig

### incomingNetworkThroughPut (string, optional) {#networkconfig-incomingnetworkthroughput}

Default: -

### outgoingNetworkThroughPut (string, optional) {#networkconfig-outgoingnetworkthroughput}

Default: -


## RackAwareness

RackAwareness defines the required fields to enable kafka's rack aware feature

### labels ([]string, required) {#rackawareness-labels}

Default: -


## CruiseControlConfig

CruiseControlConfig defines the config for Cruise Control

### cruiseControlTaskSpec (CruiseControlTaskSpec, optional) {#cruisecontrolconfig-cruisecontroltaskspec}

Default: -

### cruiseControlEndpoint (string, optional) {#cruisecontrolconfig-cruisecontrolendpoint}

Default: -

### resourceRequirements (*corev1.ResourceRequirements, optional) {#cruisecontrolconfig-resourcerequirements}

Default: -

### serviceAccountName (string, optional) {#cruisecontrolconfig-serviceaccountname}

Default: -

### imagePullSecrets ([]corev1.LocalObjectReference, optional) {#cruisecontrolconfig-imagepullsecrets}

Default: -

### nodeSelector (map[string]string, optional) {#cruisecontrolconfig-nodeselector}

Default: -

### tolerations ([]corev1.Toleration, optional) {#cruisecontrolconfig-tolerations}

Default: -

### config (string, optional) {#cruisecontrolconfig-config}

Default: -

### capacityConfig (string, optional) {#cruisecontrolconfig-capacityconfig}

Default: -

### clusterConfig (string, optional) {#cruisecontrolconfig-clusterconfig}

Default: -

### log4jConfig (string, optional) {#cruisecontrolconfig-log4jconfig}

Default: -

### image (string, optional) {#cruisecontrolconfig-image}

Default: -

### topicConfig (*TopicConfig, optional) {#cruisecontrolconfig-topicconfig}

Default: -

### cruiseControlAnnotations (map[string]string, optional) {#cruisecontrolconfig-cruisecontrolannotations}

Annotations to be applied to CruiseControl pod<br>+optional<br>

Default: -

### initContainers ([]corev1.Container, optional) {#cruisecontrolconfig-initcontainers}

InitContainers add extra initContainers to CruiseControl pod<br>

Default: -

### volumes ([]corev1.Volume, optional) {#cruisecontrolconfig-volumes}

Volumes define some extra Kubernetes Volumes for the CruiseControl Pods.<br>

Default: -

### volumeMounts ([]corev1.VolumeMount, optional) {#cruisecontrolconfig-volumemounts}

VolumeMounts define some extra Kubernetes Volume mounts for the CruiseControl Pods.<br>

Default: -

### podSecurityContext (*corev1.PodSecurityContext, optional) {#cruisecontrolconfig-podsecuritycontext}

Default: -

### securityContext (*corev1.SecurityContext, optional) {#cruisecontrolconfig-securitycontext}

SecurityContext allows to set security context for the CruiseControl container<br>

Default: -


## CruiseControlTaskSpec

CruiseControlTaskSpec specifies the configuration of the CC Tasks

### RetryDurationMinutes (int, required) {#cruisecontroltaskspec-retrydurationminutes}

RetryDurationMinutes describes the amount of time the Operator waits for the task<br>

Default: -


## TopicConfig

TopicConfig holds info for topic configuration regarding partitions and replicationFactor

### partitions (int32, required) {#topicconfig-partitions}

Default: -

### replicationFactor (int32, required) {#topicconfig-replicationfactor}

Default: -


## EnvoyConfig

EnvoyConfig defines the config for Envoy

### image (string, optional) {#envoyconfig-image}

Default: -

### resourceRequirements (*corev1.ResourceRequirements, optional) {#envoyconfig-resourcerequirements}

Default: -

### replicas (int32, optional) {#envoyconfig-replicas}

Default: -

### serviceAccountName (string, optional) {#envoyconfig-serviceaccountname}

Default: -

### imagePullSecrets ([]corev1.LocalObjectReference, optional) {#envoyconfig-imagepullsecrets}

Default: -

### nodeSelector (map[string]string, optional) {#envoyconfig-nodeselector}

Default: -

### tolerations ([]corev1.Toleration, optional) {#envoyconfig-tolerations}

Default: -

### annotations (map[string]string, optional) {#envoyconfig-annotations}

Annotations defines the annotations placed on the envoy ingress controller deployment<br>

Default: -

### loadBalancerSourceRanges ([]string, optional) {#envoyconfig-loadbalancersourceranges}

Default: -

### loadBalancerIP (string, optional) {#envoyconfig-loadbalancerip}

LoadBalancerIP can be used to specify an exact IP for the LoadBalancer service<br>

Default: -

### adminPort (*int32, optional) {#envoyconfig-adminport}

Envoy admin port<br>

Default: -


## IstioIngressConfig

IstioIngressConfig defines the config for the Istio Ingress Controller

### resourceRequirements (*corev1.ResourceRequirements, optional) {#istioingressconfig-resourcerequirements}

Default: -

### replicas (int32, optional) {#istioingressconfig-replicas}

Default: -

### nodeSelector (map[string]string, optional) {#istioingressconfig-nodeselector}

Default: -

### tolerations ([]corev1.Toleration, optional) {#istioingressconfig-tolerations}

Default: -

### annotations (map[string]string, optional) {#istioingressconfig-annotations}

Annotations defines the annotations placed on the istio ingress controller deployment<br>

Default: -

### gatewayConfig (*v1alpha3.TLSOptions, optional) {#istioingressconfig-gatewayconfig}

Default: -

### virtualServiceAnnotations (map[string]string, optional) {#istioingressconfig-virtualserviceannotations}

Default: -

### envs ([]corev1.EnvVar, optional) {#istioingressconfig-envs}

Envs allows to add additional env vars to the istio meshgateway resource<br>

Default: -


## MonitoringConfig

MonitoringConfig defines the config for monitoring Kafka and Cruise Control

### jmxImage (string, optional) {#monitoringconfig-jmximage}

Default: -

### pathToJar (string, optional) {#monitoringconfig-pathtojar}

Default: -

### kafkaJMXExporterConfig (string, optional) {#monitoringconfig-kafkajmxexporterconfig}

Default: -

### cCJMXExporterConfig (string, optional) {#monitoringconfig-ccjmxexporterconfig}

Default: -


## StorageConfig

StorageConfig defines the broker storage configuration

### mountPath (string, required) {#storageconfig-mountpath}

Default: -

### pvcSpec (*corev1.PersistentVolumeClaimSpec, required) {#storageconfig-pvcspec}

Default: -


## ListenersConfig

ListenersConfig defines the Kafka listener types

### externalListeners ([]ExternalListenerConfig, optional) {#listenersconfig-externallisteners}

Default: -

### internalListeners ([]InternalListenerConfig, required) {#listenersconfig-internallisteners}

Default: -

### sslSecrets (*SSLSecrets, optional) {#listenersconfig-sslsecrets}

Default: -

### serviceAnnotations (map[string]string, optional) {#listenersconfig-serviceannotations}

Default: -


## SSLSecrets

SSLSecrets defines the Kafka SSL secrets

### tlsSecretName (string, required) {#sslsecrets-tlssecretname}

Default: -

### jksPasswordName (string, required) {#sslsecrets-jkspasswordname}

Default: -

### create (bool, optional) {#sslsecrets-create}

Default: -

### issuerRef (*cmmeta.ObjectReference, optional) {#sslsecrets-issuerref}

Default: -

### pkiBackend (PKIBackend, optional) {#sslsecrets-pkibackend}

Default: -


## VaultConfig

VaultConfig defines the configuration for a vault PKI backend

### authRole (string, required) {#vaultconfig-authrole}

Default: -

### pkiPath (string, required) {#vaultconfig-pkipath}

Default: -

### issuePath (string, required) {#vaultconfig-issuepath}

Default: -

### userStore (string, required) {#vaultconfig-userstore}

Default: -


## AlertManagerConfig

AlertManagerConfig defines configuration for alert manager

### downScaleLimit (int, optional) {#alertmanagerconfig-downscalelimit}

DownScaleLimit the limit for auto-downscaling the Kafka cluster.<br>Once the size of the cluster (number of brokers) reaches or falls below this limit the auto-downscaling triggered by alerts is disabled until the cluster size exceeds this limit.<br>This limit is not enforced if this field is omitted or is <= 0.<br>

Default: -

### upScaleLimit (int, optional) {#alertmanagerconfig-upscalelimit}

UpScaleLimit the limit for auto-upscaling the Kafka cluster.<br>Once the size of the cluster (number of brokers) reaches or exceeds this limit the auto-upscaling triggered by alerts is disabled until the cluster size falls below this limit.<br>This limit is not enforced if this field is omitted or is <= 0.<br>

Default: -


## IngressServiceSettings

### hostnameOverride (string, optional) {#ingressservicesettings-hostnameoverride}

In case of external listeners using LoadBalancer access method the value of this field is used to advertise the<br>Kafka broker external listener instead of the public IP of the provisioned LoadBalancer service (e.g. can be used to<br>advertise the listener using a URL recorded in DNS instead of public IP).<br>In case of external listeners using NodePort access method the broker instead of node public IP (see "brokerConfig.nodePortExternalIP")<br>is advertised on the address having the following format: <kafka-cluster-name>-<broker-id>.<namespace><value-specified-in-hostnameOverride-field><br>

Default: -

### serviceAnnotations (map[string]string, optional) {#ingressservicesettings-serviceannotations}

ServiceAnnotations defines annotations which will<br>be placed to the service or services created for the external listener<br>

Default: -

### externalTrafficPolicy (corev1.ServiceExternalTrafficPolicyType, optional) {#ingressservicesettings-externaltrafficpolicy}

externalTrafficPolicy denotes if this Service desires to route external<br>traffic to node-local or cluster-wide endpoints. "Local" preserves the<br>client source IP and avoids a second hop for LoadBalancer and Nodeport<br>type services, but risks potentially imbalanced traffic spreading.<br>"Cluster" obscures the client source IP and may cause a second hop to<br>another node, but should have good overall load-spreading.<br>+optional<br>

Default: -

### serviceType (corev1.ServiceType, optional) {#ingressservicesettings-servicetype}

Service Type string describes ingress methods for a service<br>Only "NodePort" and "LoadBalancer" is supported.<br><br>

Default:  LoadBalancer


## ExternalListenerConfig

ExternalListenerConfig defines the external listener config for Kafka

###  (CommonListenerSpec, required) {#externallistenerconfig-}

Default: -

###  (IngressServiceSettings, required) {#externallistenerconfig-}

Default: -

### externalStartingPort (int32, required) {#externallistenerconfig-externalstartingport}

Default: -

### anyCastPort (*int32, optional) {#externallistenerconfig-anycastport}

configuring AnyCastPort allows kafka cluster access without specifying the exact broker<br>

Default: -

### accessMethod (corev1.ServiceType, optional) {#externallistenerconfig-accessmethod}

accessMethod defines the method which the external listener is exposed through.<br>Two types are supported LoadBalancer and NodePort.<br>The recommended and default is the LoadBalancer.<br>NodePort should be used in Kubernetes environments with no support for provisioning Load Balancers.<br><br>+optional<br>

Default:  LoadBalancer

### config (*Config, optional) {#externallistenerconfig-config}

Config allows to specify ingress controller configuration per external listener<br>if set overrides the the default `KafkaClusterSpec.IstioIngressConfig` or `KafkaClusterSpec.EnvoyConfig` for this external listener.<br>+optional<br>

Default: -


## Config

Config defines the external access ingress controller configuration

### defaultIngressConfig (string, required) {#config-defaultingressconfig}

Default: -

### ingressConfig (map[string]IngressConfig, optional) {#config-ingressconfig}

Default: -


## IngressConfig

###  (IngressServiceSettings, required) {#ingressconfig-}

Default: -

### istioIngressConfig (*IstioIngressConfig, optional) {#ingressconfig-istioingressconfig}

Default: -

### envoyConfig (*EnvoyConfig, optional) {#ingressconfig-envoyconfig}

Default: -


## InternalListenerConfig

InternalListenerConfig defines the internal listener config for Kafka

###  (CommonListenerSpec, required) {#internallistenerconfig-}

Default: -

### usedForInnerBrokerCommunication (bool, required) {#internallistenerconfig-usedforinnerbrokercommunication}

Default: -

### usedForControllerCommunication (bool, optional) {#internallistenerconfig-usedforcontrollercommunication}

Default: -


## CommonListenerSpec

CommonListenerSpec defines the common building block for Listener type

### type (SecurityProtocol, required) {#commonlistenerspec-type}

Default: -

### name (string, required) {#commonlistenerspec-name}

Default: -

### containerPort (int32, required) {#commonlistenerspec-containerport}

Default: -


## ListenerStatuses

ListenerStatuses holds information about the statuses of the configured listeners.
The internal and external listeners are stored in separate maps, and each listener can be looked up by name.

### internalListeners (map[string]ListenerStatusList, optional) {#listenerstatuses-internallisteners}

Default: -

### externalListeners (map[string]ListenerStatusList, optional) {#listenerstatuses-externallisteners}

Default: -


## ListenerStatus

ListenerStatus holds information about the address of the listener

### name (string, required) {#listenerstatus-name}

Default: -

### address (string, required) {#listenerstatus-address}

Default: -


## KafkaCluster

KafkaCluster is the Schema for the kafkaclusters API

###  (metav1.TypeMeta, required) {#kafkacluster-}

Default: -

### metadata (metav1.ObjectMeta, optional) {#kafkacluster-metadata}

Default: -

### spec (KafkaClusterSpec, optional) {#kafkacluster-spec}

Default: -

### status (KafkaClusterStatus, optional) {#kafkacluster-status}

Default: -


## KafkaClusterList

KafkaClusterList contains a list of KafkaCluster

###  (metav1.TypeMeta, required) {#kafkaclusterlist-}

Default: -

### metadata (metav1.ListMeta, optional) {#kafkaclusterlist-metadata}

Default: -

### items ([]KafkaCluster, required) {#kafkaclusterlist-items}

Default: -


