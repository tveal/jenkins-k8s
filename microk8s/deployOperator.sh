#!/bin/bash
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
k=microk8s.kubectl
set -e

# depends on microk8s running
$k apply -f $THIS_DIR/../jenkins-operator/deploy/crds/jenkinsio_v1alpha1_jenkins_crd.yaml
$k apply -f $THIS_DIR/../jenkins-operator/deploy/service_account.yaml
$k apply -f $THIS_DIR/../jenkins-operator/deploy/role.yaml
$k apply -f $THIS_DIR/../jenkins-operator/deploy/role_binding.yaml
$k apply -f $THIS_DIR/../jenkins-operator/deploy/operator.yaml
watch $k get pods