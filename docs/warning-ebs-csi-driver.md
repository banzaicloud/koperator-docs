---
---
{{< warning >}}Both ZooKeeper clsuter and Kafka cluster need [persistent volume (PV)](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) to store data. Therefore, when installing the operator on Amazon EKS with Kuberentes version >= 1.23, you [must install the EBS CSI driver add-on](https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html) on your cluster. {{< /warning >}}
