---
title: CruiseControlOperation to manage Cruise Control
shorttitle: Cruise Control Operations
weight: 200
---


From `Koperator` v1.21+ we have introduced the `CruiseControlOperation` custom resource. Koperator executes the Cruise Control related task based on our `CruiseControlOperation` custom resource state. This way we could get better control over Cruise Control. This better control gives us more reliability, configurability, observability and it also gives us more room for future improvements.

## How it works?

When a broker is added or removed from the  Kafka cluster or when a new storage is added for a broker the Koperator creates a `CruiseControlOperation` custom resource.
This created custom resource describes a task what will be executed by CruseControl to do the partitions movements.
Koperator watches the created `CruiseControlOperation` custom resource and updates their state based on the result of the CruiseControl task.  
Koperator can re-execute the task when it has failed.  
When there are multiple `CruiseControlOperation` at the same time CruiseControl is not able to execute more then one task thus we added a priority between the tasks depending their operation type.  
Upscale operations will be executed first then downscale operations and after rebalance operations.  
Currently three CruiseControl tasks are supported.  
The [add_broker](https://github.com/linkedin/cruise-control/wiki/REST-APIs#add-a-list-of-new-brokers-to-kafka-cluster), [remove_broker](https://github.com/linkedin/cruise-control/wiki/REST-APIs#decommission-a-list-of-brokers-from-the-kafka-cluster), and the [rebalance](https://github.com/linkedin/cruise-control/wiki/REST-APIs#trigger-a-workload-balance).  
The process of the operation can be followed up through the `KafkaCluster` custom resource's status and through the created `CruiseControlOperation` custom resource's status.  
In the section below you can see an example for the `add_broker` (`GracefulUpscale*`) operation but the same applies for the Kafka cluster `remove_broker` (`GracefulDownScale*`) and `rebalance` (when the `volumeState` is `GracefulDiskRebalance*`) operations.

1. Upscale the Kafka cluster by adding a new broker with id "3" into the `KafkaCluster` CR:

```yaml
 Spec:
 ...  
   brokers:
    - id: 0
      brokerConfigGroup: "default"
    - id: 1
      brokerConfigGroup: "default"
    - id: 2
      brokerConfigGroup: "default"
    - id: 3
      brokerConfigGroup: "default"
...
```

2. A new broker pod will be created and in the `KafkaCluster` status there will be the `cruiseControlOperationReference`.  
   This is the reference of the created `CruiseControlOperation` custom resource.  
   The `cruiseControlState` shows the CruiseControlOperation state.  
   At first there will be GracefulUpscaleScheduled.  
   This means `CruiseControlOperation` is created and it is waiting for `add_broker` task execution.

```yaml
status:
...
  brokersState:
    "3":
     ...
      gracefulActionState:
        cruiseControlOperationReference:
          name: kafka-addbroker-mhh72
        cruiseControlState: GracefulUpscaleScheduled
        volumeStates:
          /kafka-logs:
            cruiseControlOperationReference:
              name: kafka-rebalance-h6ntt
            cruiseControlVolumeState: GracefulDiskRebalanceScheduled
          /kafka-logs2:
            cruiseControlOperationReference:
              name: kafka-rebalance-h6ntt
            cruiseControlVolumeState: GracefulDiskRebalanceScheduled
    ...
```

3. When the `add_broker` Cruise Control task is under execution:

```yaml
status:
...
  brokersState:
    "3":
     ...
      gracefulActionState:
        cruiseControlOperationReference:
          name: kafka-addbroker-mhh72
        cruiseControlState: GracefulUpscaleRunning
    ...
```

4. When the `add_broker` Cruise Control task is completed:

```yaml
status:
...
  brokersState:
    "3":
     ...
      gracefulActionState:
        cruiseControlOperationReference:
          name: kafka-addbroker-mhh72
        cruiseControlState: GracefulUpscaleSucceeded
    ...
```

There are two other `cruiseControlState`s which has not been covered by the above example.  
The `GracefulUpscaleCompletedWithError` and the `GracefulUpscalePaused`.  
The `GracefulUpscalePaused` is a special state and there are more details about it in the next section.  
The `GracefulUpscaleCompletedWithError` happens  when the Cruise Control task is failed somehow.
In this case when the `cruiseControlOperation.spec.errorPolicy` is set to `retry`, (`retry` is the default value) the failed task will be re-executed by Koperator in every `30s` until it is succeeded.  
When it is re-executed the `cruiseControlState` will be GracefulUpscaleRunning again.

```yaml
status:
...
  brokersState:
    "3":
     ...
      gracefulActionState:
        cruiseControlOperationReference:
          name: kafka-addbroker-mhh72
        cruiseControlState: GracefulUpscaleCompletedWithError
    ...
```

The kafka-addbroker-mhh72 `CruiseControlOperation` from the above example:

```yaml
kind: CruiseControlOperation
metadata:
...
  name: kafka-addbroker-mhh72
...
spec:
...
status:
  currentTask:
    finished: "2022-11-18T09:31:40Z"
    httpRequest: http://kafka-cruisecontrol-svc.kafka.svc.cluster.local:8090/kafkacruisecontrol/add_broker?allow_capacity_estimation=true&brokerid=3&data_from=VALID_WINDOWS&dryrun=false&exclude_recently_demoted_brokers=true&exclude_recently_removed_brokers=true&json=true&use_ready_default_goals=true
    httpResponseCode: 200
    id: 222e30f0-1e7a-4c87-901c-bed2854d69b7
    operation: add_broker
    parameters:
      brokerid: "3"
      exclude_recently_demoted_brokers: "true"
      exclude_recently_removed_brokers: "true"
    started: "2022-11-18T09:30:48Z"
    state: Completed
    summary:
      Data to move: "0"
      Intra broker data to move: "0"
      Number of intra broker replica movements: "0"
      Number of leader movements: "0"
      Number of replica movements: "36"
      Provision recommendation: '[ReplicaDistributionGoal] Remove at least 4 brokers.'
      Recent windows: "1" 
  errorPolicy: retry
  retryCount: 0
```

The `status.currentTask` describes the Cruise Control task.  
The `httpRequest` field contains the whole POST HTTP request that has been executed.  
The `id` is the Cruise Control task identifier number.  
The `state` shows the progress of the add_broker request.  
The `summary` is Cruise Control's optimization proposal.  
It shows the scope of the changes that Cruise Control will apply through the operation.  
When a task execution is completed with error and there are re-executions the `retryCount` shows the number of retries.  
In this case the history of the failed tasks are visible with the error message in the `status.failedTask` field.  
You can also find information on the fields [here](https://github.com/banzaicloud/koperator/blob/master/api/v1alpha1/cruisecontroloperation_types.go)

## How can we have control over the created CruiseControlOperation?

- The task execution can be stopped gracefully when the `CruiseControlOperation` is deleted. In this case the corresponding `cruiseControlState` or the `cruiseControlVolumeState` will transition to `Graceful*Succeeded`.
- `cruiseControlOperation.spec.errorPolicy` defines how the failed Cruise Control task should be handled. When the `errorPolicy` is `retry`, Koperator re-executes the failed task every `30s`. When it is "ignore", Koperator handles the failed task as completed thus the `cruiseControlState` or the `cruiseControlVolumeState` will transition to `Graceful*Succeeded`.
- When there is a Cruise Control task which can not be completed without an error and the `cruiseControlOperation.spec.errorPolicy` is retry, Koperator will re-execute the task until it is succeeded.  
This automatic re-execution can be paused with a label on the corresponding `CruiseControlOperation` custom resource (check the example below setting the label `pause` to the value `true`).  
When the `pause` label is not set to `true` or the label is removed, the re-execution will be continued.  
Pausing can be useful when the reason of the error cannot be fixed any time soon but you want to retry the operation later when the problem is resolved.  
A paused `CruiseControlOperation` will not be considered as a choice when selecting operation for execution.  
It means when a new `CruiseControlOperation` with same operation (`status.currentTask.operation`) type is created the new one will be executed and the paused one will be skipped.

```yaml
kind: CruiseControlOperation
metadata:
...
  name: kafka-addbroker-mhh72
  labels:
    pause: "true"
...
```

- You can set automatic cleanup time for the created `CruiseControlOperations` in the `KafkaCluster` custom resource.  
   In the above example the finished (completed successfully or `completedWithError` and `errorPolicy: ignore`) `CruiseControlOperation` custom resources will be deleted after the `300s` elapsed after finishing the particular operation.

```yaml
apiVersion: kafka.banzaicloud.io/v1beta1
kind: KafkaCluster
...
spec:
...
  cruiseControlConfig:
    cruiseControlOperationSpec:
      ttlSecondsAfterFinished: 300
...
```

### Example for the ignore and pause use-cases

1. In the first example we extended the Kafka cluster with one broker. Now we will remove 2 brokers at the same time by editing the `KafkaCluster` custom resource.

```yaml
 Spec:
 ...  
   brokers:
    - id: 0
      brokerConfigGroup: "default"
    - id: 1
      brokerConfigGroup: "default"
```

2. There will be `remove_broker` operations for both brokers (kafka-removebroker-lg7qm, kafka-removebroker-4plfq). The first one is already in running state in the example below.

```yaml
status:
...
  brokersState:
    "2":
     ...
      gracefulActionState:
        cruiseControlOperationReference:
          name: kafka-removebroker-lg7qm
        cruiseControlState: GracefulDownscaleRunning
     ...
     "3":
     gracefulActionState:
        cruiseControlOperationReference:
          name: kafka-removebroker-4plfq
        cruiseControlState: GracefulDownscaleScheduled
    ...
```

3. We assume that something unexpected happened this time so the remove_broker operation will get `GracefulDownscaleCompletedWithError` state.

```yaml
status:
...
  brokersState:
    "2":
     ...
      gracefulActionState:
        cruiseControlOperationReference:
          name: kafka-removebroker-lg7qm
        cruiseControlState: GracefulDownscaleCompletedWithError
     ...
     "3":
     gracefulActionState:
        cruiseControlOperationReference:
          name: kafka-removebroker-4plfq
        cruiseControlState: GracefulDownscaleScheduled
    ...
```

4. At this point we can decide to let this problematic operation to be retried which is the default behavior or `ignore` the error or use the `pause` label to pause the retry execution and let Koperator execute the next operation.

- Ignore use-case:  This time the ignore has been chosen by setting of the `cruiseControlOperation.spec.errorPolicy` to `ignore`.  
   This operation will be considered as a succeeded operation thus the broker pod and the persistent volume will be removed from the Kubernetes cluster and from the `KafkaCluster` status.  
   The `Koperator` will execute the next `remove_broker` (`kafka-removebroker-4plfq`) `CruiseControlOperation`.

```yaml
status:
...
  brokersState:
    ...
     "3":
     gracefulActionState:
        cruiseControlOperationReference:
          name: kafka-removebroker-4plfq
        cruiseControlState: GracefulDownscaleRunning
    ...
```

- Pause use-case: This time the pause has been chosen by the set of a `pause: true` label for the `kafka-removebroker-lg7qm` `CruiseControlOperation`.  
  The re-execution is paused and Koperator will execute the next `remove_broker` operation.

```yaml
status:
...
  brokersState:
    "2":
     ...
      gracefulActionState:
        cruiseControlOperationReference:
          name: kafka-removebroker-lg7qm
        cruiseControlState: GracefulDownscalePaused
     ...
     "3":
     gracefulActionState:
        cruiseControlOperationReference:
          name: kafka-removebroker-4plfq
        cruiseControlState: GracefulDownscaleRunning
    ...
```

When the second `remove_broker` operation is finished:

```yaml
status:
...
  brokersState:
    "2":
     ...
      gracefulActionState:
        cruiseControlOperationReference:
          name: kafka-removebroker-lg7qm
        cruiseControlState: GracefulDownscalePaused
     ...
```

We assume that the problematic situation has been resolved thus we can let the `remove_broker` operation be retired by removing the `pause` label thus the operation will be re-executed.

```yaml
status:
...
  brokersState:
    "2":
     ...
      gracefulActionState:
        cruiseControlOperationReference:
          name: kafka-removebroker-lg7qm
        cruiseControlState: GracefulDownscaleRunning
     ...
```

This time everything went well so the broker has been removed.
