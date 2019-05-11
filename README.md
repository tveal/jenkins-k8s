# Jenkins in a Kubernetes Cluster

A playground to test Jenkins in a Kubernetes cluster locally using MicroK8s (Linux).
See [Helpful Links](#Helpful-Links) below.

Goals:
- Build-agnostic agents; configured in project source code - Jenkins should not have specific build settings
- Scalable
- Configuration as code
- Can be spun up locally without a remote cloud/infra dependency
- ...

Table of Contents
- [Spin up Jenkins on MicroK8s](#Spin-up-Jenkins-on-MicroK8s)
- [Tear Down](#Tear-Down)
- [Advanced: Serve up a local directory of git projects](#Serve-up-a-local-directory-of-git-projects)
- [Advanced: Store SSH Key in K8s](#Store-SSH-Key-in-K8s)
- [Pull in latest kubernetes-operator](#Pull-in-latest-kubernetes-operator)
- [Troubleshooting](#Troubleshooting)
- [Helpful Links](#Helpful-Links)

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

## Advanced

### Serve up a local directory of git projects

Example folder structure:

```
my-public-repos/
    - repo-a/
    - repo-b/
    - repo-c/
    ...
```

To serve up all repos in `my-public-repos` on your IP, run the following inside one of the repos,
such as `repo-a`; This creates the _quickserve_ alias in that repo.

```bash
git config --global alias.quickserve "daemon --verbose --export-all --base-path=../ --reuseaddr"
```

Then in the same repo, run the command:

```bash
git quickserve
```

You can then run `git clone git://localhost/repo-b` in a _separate_ terminal to clone _repo-b_.
Use this to serve up test repos for playing with Jenkins locally.
**To use inside a k8s cluster, you'll need to use your inet IP of your real network device (use `ifconfig`).**
For the original inspiration for this trick, see
[A one-off git repo server](https://datagrok.org/git/git-serve/).

### Store SSH Key in K8s

```bash
microk8s.kubectl create secret generic k8s-ssh --from-file=privateKey=</path/to/.ssh/id_rsa> --from-literal=username=<your-username>
```
_This must be an RSA SSH key; ED25519 does not work._

See [SSH authentication](jenkins-operator/docs/getting-started.md#SSH-authentication)
in jenkins-operator/docs/getting-started.md

## Pull in latest kubernetes-operator

The _jenkins-operator_ folder in this project is a clone of
[kubernetes-operator](https://github.com/jenkinsci/kubernetes-operator).
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

If you exit the busybox shell, but it is still running, you can reconnect
to a shell with:

```bash
kubectl exec -it <busybox pod name> -- sh
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