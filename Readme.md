# kube-node-lifecycle-labeller

Very basic Kubernetes DaemonSet which sets labels and taints based on EC2 LifeCycle of a node.

This is most useful for AWS AutoScalingGroups with MixedInstancePolicies where labels and taints needs to be controlled on a node-by-node basis

## Kubernetes deployment

See [Chart README](deploy/chart/README.md)

```shell
make manifests # uses local helm chart and helm template to render manifests
kubectl apply -f deploy/manifests/
```

Results:

```shell
> k get no -l kops.k8s.io/instancegroup=nodes-mix -L LifeCycle
NAME                                             STATUS   ROLES   AGE   VERSION   LIFECYCLE
ip-10-89-4-139.ap-southeast-1.compute.internal   Ready    node    23h   v1.15.3   Ec2Spot
ip-10-89-5-106.ap-southeast-1.compute.internal   Ready    node    23h   v1.15.3   OnDemand

> k get no -l kops.k8s.io/instancegroup=nodes-mix -o json | jq '.items[] | {"Name":.metadata.name,"Labels":.metadata.labels,"Taints":.spec.taints}'
{
  "Name": "ip-*******.ap-southeast-1.compute.internal",
  "Labels": {
    "LifeCycle": "Ec2Spot",
    "beta.kubernetes.io/arch": "amd64",
    "beta.kubernetes.io/instance-type": "t3.xlarge",
    "beta.kubernetes.io/os": "linux",
    "failure-domain.beta.kubernetes.io/region": "ap-southeast-1",
    "failure-domain.beta.kubernetes.io/zone": "ap-southeast-1a",
    "kops.k8s.io/instancegroup": "nodes-mix",
    "kubernetes.io/arch": "amd64",
    "kubernetes.io/hostname": "ip-*******.ap-southeast-1.compute.internal",
    "kubernetes.io/os": "linux",
    "kubernetes.io/role": "node",
    "node-role.kubernetes.io/node": ""
  },
  "Taints": [
    {
      "effect": "PreferNoSchedule",
      "key": "spotInstance",
      "value": "true"
    }
  ]
}
{
  "Name": "ip-***********.ap-southeast-1.compute.internal",
  "Labels": {
    "LifeCycle": "OnDemand",
    "beta.kubernetes.io/arch": "amd64",
    "beta.kubernetes.io/instance-type": "m4.xlarge",
    "beta.kubernetes.io/os": "linux",
    "failure-domain.beta.kubernetes.io/region": "ap-southeast-1",
    "failure-domain.beta.kubernetes.io/zone": "ap-southeast-1b",
    "kops.k8s.io/instancegroup": "nodes-mix",
    "kubernetes.io/arch": "amd64",
    "kubernetes.io/hostname": "ip-***********.ap-southeast-1.compute.internal",
    "kubernetes.io/os": "linux",
    "kubernetes.io/role": "node",
    "node-role.kubernetes.io/node": ""
  },
  "Taints": null
}
```
