#!/bin/bash
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
k=microk8s.kubectl
set -e

# depends on microk8s running with dns AND public internet
$k apply -f $THIS_DIR/../jenkins-instance/jenkins_instance.yaml
watch $k get pods