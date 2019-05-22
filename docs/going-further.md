# Going Further

Table of Contents
- [Advanced: Serve up a local directory of git projects](#Serve-up-a-local-directory-of-git-projects)
- [Troubleshooting](#Troubleshooting)
- [Helpful Links](#Helpful-Links)


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

## Troubleshooting

Use the following to spin up a busybox in k8s and enter an interactive shell
```bash
kubectl run -it busybox --image=busybox:1.28 -- sh
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
- [Debugging DNS Resolution](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/)
- [kubectl cheat sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
