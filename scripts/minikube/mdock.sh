#!/bin/bash

# connects docker to VM's docker-daemon
eval $(minikube docker-env)

docker $@