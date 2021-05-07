
pipeline {

    agent any

    options {
        timestamps()
        ansiColor('xterm')
        buildDiscarder logRotator(numToKeepStr: '100')
        disableConcurrentBuilds()
        timeout(activity: true, time: 1, unit: 'DAYS')
    }

    parameters {
        string defaultValue: 'master', description: 'Builder scaffold Git branch', name: 'GIT_BRANCH', trim: true
        string defaultValue: 'git@github.com:balena-io/python-build.git', description: 'Builder scaffold Git repository', name: 'GIT_URL', trim: true
        string defaultValue: '', description: 'Space separated list of architectures to build (e.g.) armel armv6hf armv7hf amd64 i386 alpine-armhf alpine-i386 alpine-amd64 alpine-aarch64 fedora-armhf aarch64 fedora-aarch64', name: 'ARCHS', trim: true
        string defaultValue: '', description: 'Space separated list of Python versions to build (e.g.) 3.9.0 3.91', name: 'PYTHON_VERSIONS', trim: true
        string defaultValue: 'resin-packages', description: 'AWS/S3 output bucket', name: 'BUCKET_NAME', trim: true
        credentials credentialType: 'com.cloudbees.jenkins.plugins.awscredentials.AWSCredentialsImpl', defaultValue: '273bf5c6-1411-46c3-b0d5-6469e84d50ff', description: 'AWS/IAM credentials', name: 'AWS_CREDENTIALS', required: true
        credentials credentialType: 'com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey', defaultValue: 'a2d8eaf4-a373-4efa-a9e3-c331a3687e72', description: 'GitHub credentials', name: 'GIT_CREDENTIALS', required: true
    }

    stages {

        stage('scm') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/${GIT_BRANCH}']],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [],
                    submoduleCfg: [],
                    userRemoteConfigs: [[
                        credentialsId: GIT_CREDENTIALS, 
                        url: GIT_URL
                    ]
                ]])
            }
        }

        stage('build') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding', 
                    accessKeyVariable: 'ACCESS_KEY', 
                    credentialsId: AWS_CREDENTIALS, 
                    secretKeyVariable: 'SECRET_KEY'
                ]]) {
                    sh returnStdout: true, script: 'automation/jenkins_build.sh'
                }
            }
        }
    }
}
