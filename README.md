# Jenkins for Kubernetes Cluster

Why?
- Build-agnostic agents; configured in app source code - Jenkins should not have specific build settings
- Scalable
- Configuration as code - control Jenkins from version control
- Replicate locally without a remote cloud/infra dependency

## High Level Overview

Given you have a running Kubernetes cluster and `kubectl`:

1. Deploy your k8s **secrets** - refer to [scripts/secrets/deploySecrets](scripts/secrets/deploySecrets.sh)
2. Deploy the **jenkins-operator** - refer to [scripts/deployOperator.sh](scripts/deployOperator.sh)
3. Deploy the **jenkins-instance** - refer to [scripts/deployInstance.sh](scripts/deployInstance.sh)


---

![](docs/img/warning-circle-orange-32.png)

For private corporate certs, the Jenkins master image needs a custom build, see
[jenkins-docker/Dockerfile](jenkins-docker/Dockerfile).
For local, you can use [scripts/minikube/docker-build.sh](scripts/minikube/docker-build.sh)
to build this image inside the minikube cluster.

TIP: Use SSH to checkout repos on the build agents to avoid having to pre-patch every single
docker image you consume with certs. If a repo's build needs certs, it can configure them
after the checkout and before the build tasks (such as an init stage). Again, the goal here
is to keep Jenkins build-agnostic.

---

Ready to jump in? Start the journey at [docs/getting-started.md](docs/getting-started.md).
Already rockin' Jenkins-in-K8s? See [docs/going-further.md](docs/going-further.md).
