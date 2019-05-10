# MicroK8s

>A single package of k8s that installs on 42 flavours of Linux. Made for developers and great for appliances.

https://microk8s.io/

[codefresh comparison of Minikube and MicroK8s](https://codefresh.io/kubernetes-tutorial/local-kubernetes-linux-minikube-vs-microk8s/)

## Common Commands

```bash
microk8s.start
```

You almost _always_ want dns enabled

```bash
microk8s.enable dns
```

Determine if microk8s is running and which addons are enabled

```bash
microk8s.status
```

Run this and check for any warnings

```bash
microk8s.inspect
```

Stop microk8s (keeps config)

```bash
microk8s.stop
```

Show all the things for all namespaces

```bash
microk8s.kubectl get all --all-namespaces
```