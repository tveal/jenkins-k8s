#!/bin/bash
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
set -e

k=kubectl
opDir="$THIS_DIR/../jenkins-operator"

$k apply -f $opDir/crds/jenkinsio_v1alpha1_jenkins_crd.yaml
$k apply -f $opDir/service_account.yaml
$k apply -f $opDir/role.yaml
$k apply -f $opDir/role_binding.yaml
$k apply -f $opDir/operator.yaml
watch $k get pods