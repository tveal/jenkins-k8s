# Jenkins in a Kubernetes Cluster

A playground to test Jenkins in a Kubernetes cluster locally using MicroK8s (Linux).
See [Helpful Links](#Helpful-Links) below.

Goals:
- Build-agnostic agents; configured in project source code - Jenkins should not have specific build settings
- Scalable
- Configuration as code
- Can be spun up locally without a remote cloud/infra dependency
- ...

## Spin up Jenkins on MicroK8s

### Get the K8s cluster ready

1. Run the [microk8s/install.sh](microk8s/install.sh) script
2. Run the command `microk8s.status`, if not ready yet, wait and run again until microk8s is running
3. Run the [microk8s/configure.sh](microk8s/configure.sh) script; **address any warnings, espically about IPtables**

### Deploy Jenkins to K8s

1. With MicroK8s running, run [microk8s/deployOperator.sh](microk8s/deployOperator.sh)
2. Press `Ctrl + c` to exit the watch command once the operator pod is ready
3. Run the [microk8s/deployInstance.sh](microk8s/deployInstance.sh) script, and press `Ctrl + c`
to exit the watch command whenever the instance is ready
4. Get Jenkins credentials:

```bash
echo "$(microk8s.kubectl get secret jenkins-operator-credentials-example -o 'jsonpath={.data.user}' | base64 -d)"
echo "$(microk8s.kubectl get secret jenkins-operator-credentials-example -o 'jsonpath={.data.password}' | base64 -d)"
```

5. Get Jenkins instance endpoint to visit in the browser

```bash
microk8s.kubectl get endpoints jenkins-operator-http-example
```

6. Visit the endpoint from #5 in a browser using the credentials from #4

## Tear Down

- To completely remove Jenkins + MicroK8s, run [microk8s/remove.sh](microk8s/remove.sh)
- OR To stop the mircok8s cluster: `microk8s.stop`
    - If you just stop the k8s cluster, you can start it back with
    `microk8s.start`. You'll have to lookup the new endpoint though.

## Pull in latest kubernetes-operator

The _jenkins-operator_ folder in this project is a clone of [kubernetes-operator](https://github.com/jenkinsci/kubernetes-operator).
You can add the original source repo as an additional remote to pull in the latest. For merge conflicts, keep in mind
that all the source of _kubernetes-operator_ was moved into the sub-folder _jenkins-operator_.

```bash
git remote add og https://github.com/jenkinsci/kubernetes-operator.git
git pull og master
```

## Troubleshooting

Use the following to spin up a busybox in k8s and enter an interactive shell
```bash
microk8s.kubectl run -it busybox --image=busybox:1.28 -- sh
```
You can then test things such as DNS from inside a pod on k8s
```bash
nslookup google.com
```

## Helpful Links

Jenkins
- [Kubernetes Operator [GitHub]](https://github.com/jenkinsci/kubernetes-operator)
- [Kubernetes native Jenkins Operator](https://medium.com/virtuslab/kubernetes-native-jenkins-operator-cbdfbbecf744)

Kubernetes
- [MicroK8s Homepage](https://microk8s.io/)
- [MicroK8s [GitHub]](https://github.com/ubuntu/microk8s)
    - [Reaching public internet](https://github.com/ubuntu/microk8s#my-pods-cant-reach-the-internet-or-each-other-but-my-microk8s-host-machine-can)
- [Debugging DNS Resolution](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/)
- [kubectl cheat sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)