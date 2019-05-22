#!/usr/bin/env groovy

pipelineJob('sample-pipeline-git') {
    displayName('Sample CI/CD Pipeline with Git Source')

    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('git@github.com:tveal/jenkins-k8s.git')
                        credentials('jenkins-k8s-ssh')
                    }
                    branches('*/master')
                }
            }
            scriptPath('cicd/pipelines/build.groovy')
        }
    }
}