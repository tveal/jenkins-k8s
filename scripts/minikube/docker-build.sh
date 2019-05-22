#!/bin/bash
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

set -e

"$THIS_DIR/../secrets/prepare.sh"

# connects docker to VM's docker-daemon
eval $(minikube docker-env)

cd $THIS_DIR/../../
docker build -t corp-jenkins -f jenkins-docker/Dockerfile .