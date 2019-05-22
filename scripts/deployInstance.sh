#!/bin/bash
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
set -e

k=kubectl
instDir="$THIS_DIR/../jenkins-instance"

$k apply -f $instDir/user-config.yaml
$k apply -f $instDir/jenkins-instance.yaml
watch $k get pods