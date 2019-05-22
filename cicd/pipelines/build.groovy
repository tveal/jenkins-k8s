#!/usr/bin/env groovy

def label = "node8-${UUID.randomUUID().toString()}"
def home = "/home/jenkins"
def workspace = "${home}/workspace/build-my-proj"
def workdir = "${workspace}/src/localhost/my-proj/"

podTemplate(label: label,
        containers: [
                containerTemplate(name: 'jnlp', image: 'jenkins/jnlp-slave:alpine'),
                containerTemplate(name: 'node', image: 'node:8', command: 'cat', ttyEnabled: true,
                envVars: [ // from kubernetes secrets
                    secretEnvVar(key: 'NPM_TOKEN', secretName: 'jenkins-k8s-npm-token', secretKey: 'NPM_TOKEN'),
                    secretEnvVar(key: 'AWS_ACCESS_KEY_ID',secretName: 'jenkins-k8s-aws-dev', secretKey: 'AWS_ACCESS_KEY_ID'),
                    secretEnvVar(key: 'AWS_SECRET_ACCESS_KEY', secretName: 'jenkins-k8s-aws-dev', secretKey: 'AWS_SECRET_ACCESS_KEY'),
                ]),
        ]) {

    node(label) {
        dir(workdir) {
            stage('Checkout') {
                timeout(time: 3, unit: 'MINUTES') {
                    checkout scm
                }
            }

            stage('Build') {
                container('node') {
                    sh 'npm install'
                    sh 'npm test'
                }
            }
        }
    }
}