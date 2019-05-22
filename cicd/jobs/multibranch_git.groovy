#!/usr/bin/env groovy

multibranchPipelineJob('sample-multibranch-git') {
    displayName('Sample CI/CD Multibranch with Git Source')
    
    branchSources {
        git {
            id = 'jenkins-k8s-multibranch-git'
            remote('git@github.com:tveal/jenkins-k8s.git')
            credentialsId('jenkins-k8s-ssh')
        }
    }

    factory {
        workflowBranchProjectFactory {
            scriptPath('cicd/pipelines/build.groovy')
        }
    }
}