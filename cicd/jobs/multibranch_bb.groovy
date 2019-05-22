#!/usr/bin/env groovy

multibranchPipelineJob('sample-multibranch-bb') {
    displayName('Sample CI/CD Multibranch with Bitbucket Source Plugin')
    
    // https://issues.jenkins-ci.org/browse/JENKINS-39977
    branchSources {
        branchSource {
            source {
                bitbucket {
                    id('multibranch-bb')
                    repoOwner('MYPROJ')
                    repository('my-bitbucket-repo')
                    autoRegisterHook(true)
                    credentialsId('jenkins-k8s-http-user')
                    traits {
                        sshCheckoutTrait {
                            credentialsId('jenkins-k8s-ssh')
                        }
                    }
                }
            }
        }
    }
    // https://gist.github.com/tknerr/c79a514db4bdbfb4956aaf0ee53836c8
    // discover Branches (workaround due to JENKINS-46202)
    configure {
        def traits = it / sources / data / 'jenkins.branch.BranchSource' / source / traits
        traits << 'com.cloudbees.jenkins.plugins.bitbucket.BranchDiscoveryTrait' {
            strategyId(3) // detect all branches
        }
    }

    factory {
        workflowBranchProjectFactory {
            scriptPath('cicd/pipelines/build.groovy')
        }
    }
}