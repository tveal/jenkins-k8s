#!/bin/bash
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

USR="$(kubectl get secret jenkins-operator-credentials-example -o 'jsonpath={.data.user}' | base64 -d)"
PASS="$(kubectl get secret jenkins-operator-credentials-example -o 'jsonpath={.data.password}' | base64 -d)"

echo ">> Make sure you run this command in another terminal:"
echo "kubectl port-forward jenkins-operator-example 8080:8080"
echo
echo $USR
echo $PASS
xdg-open "http://localhost:8080/plugin/job-dsl/api-viewer/index.html"
xdg-open "http://localhost:8080"
