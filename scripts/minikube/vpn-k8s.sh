#!/bin/bash
set -e

# https://github.com/kubernetes/minikube/issues/1099#issuecomment-307154111
VBoxManage controlvm minikube natpf1 k8s-apiserver,tcp,127.0.0.1,8443,,8443 || echo "NAT might already be configured."
kubectl config set-cluster minikube-vpn --server=https://127.0.0.1:8443 --insecure-skip-tls-verify
kubectl config set-context minikube-vpn --cluster=minikube-vpn --user=minikube
kubectl config use-context minikube-vpn