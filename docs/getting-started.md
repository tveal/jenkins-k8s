# Getting Started

Run Jenkins in a local kubernetes cluster! The best local k8s solution for this project is **Minikube**.
If you're curious, see [What about MicroK8s?](#What-about-MicroK8s?)

## Install the Tools

1. Install Docker. For Ubuntu-based distros, use [scripts/docker/install-on-ubuntu.sh](../scripts/docker/install-on-ubuntu.sh),
otherwise see [About Docker CE](https://docs.docker.com/install/)
2. Install Minikube and kubectl following the steps for your platform [here](https://kubernetes.io/docs/tasks/tools/install-minikube/).
**Use VirtualBox for the Hypervisor.**

---

![](img/warning-circle-orange-32.png)

Minikube uses 2048 MB of RAM by default; Not enough for this project, as it causes
the readiness/liveness probes to fail indefinitely.

Instead, your _first_ minikube start command should specify more RAM:

```
minikube start --cpus 2 --memory 6144
```

---

## Run Everything Local

1. Start up minikube if you haven't already. For 2nd+ times, you can use `minikube start`; To stop, `minikube stop`.
2. Run [scripts/minikube/docker-build.sh](../scripts/minikube/docker-build.sh)
3. Run [scripts/secrets/deploySecrets.sh](../scripts/secrets/deploySecrets.sh).
The first time this runs, it will generate a new ssh key pair and fake username/password
secrets to deploy to k8s. When you change the local creds, rerun this script to update
the k8s secrets.
4. Run [scripts/deployOperator.sh](../scripts/deployOperator.sh). Press `Ctrl+C` to escape
the watch command. Use `kubectl` commands to examine logs if you like.
5. Run [scripts/deployInstance.sh](../scripts/deployInstance.sh). This one takes a while.
Again, press `Ctrl+C` to escape the watch command. Strongly suggest following these logs, `kubectl logs -f <jenkins instance pod name>`.

If everything played nicely this far, you should have a running Jenkins instance in a local minikube k8s cluster. The jenkins-operator will manage that instance, keeping it in-sync with configmaps, and auto-restarting as needed.

### To visit the Jenkins UI in a browser:

1. In one terminal, start a port-forward to the Jenkins instance pod, such as:

    ```bash
    kubectl port-forward jenkins-operator-example 8080:8080
    ```

2. In another terminal, run [scripts/minikube/open-browser.sh](../scripts/minikube/open-browser.sh) -
This will open both the Dynamic DSL and Jenkins Login pages in a browser. Refer back to this terminal for the login details.

## AnyConnect VPN

You _can_ run this Jenkins K8s project locally when connected to your corporate VPN, but it takes some workarounds.
First, the [scripts/minikube/docker-build.sh](../scripts/minikube/docker-build.sh) _cannot_ be run
on an active VPN connection, so run that before you connect. If you haven't downloaded the corporate certs yet,
you'll probably have to VPN for those, then disconnect... Ugh! Once the local docker build
is out of the way, you can connect to VPN. Kubectl will stop working though, so we have to port-forward
on the VirtualBox instance, and add a new kubectl context. This also means that if you were using kubectl to
forward port 8080 to your local Jenkins pod, you'll have to stop that process and start again after the following change.

Fix kubectl when on VPN connection:
- [scripts/minikube/vpn-k8s.sh](../scripts/minikube/vpn-k8s.sh)

Restore kubectl when _off_ VPN connection:
- [scripts/minikube/vpn-off-k8s.sh](../scripts/minikube/vpn-off-k8s.sh)

## What about MicroK8s?

MicroK8s can work if you don't have complex corporate network infrastructure, such as internal DNS and privately signed certs.
On one hand, MicroK8s (on Linux) is easiest to install and nicely sandboxed from any other k8s config/cluster you might have.
On the other hand, you could be in for a world of pain with networking woes - Minikube gets the DNS correct right out of the box.

If you use AnyConnect to VPN to work, both MicroK8s and Minikube have problems, but there's more community support for Minikube.
This project includes scripts to make Minikube work on/off VPN (see above).
