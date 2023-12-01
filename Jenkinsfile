pipeline {
    agent any
    tools {
        terraform 'terraform'
    }
    stages {
        stage('checkout code') {
            steps {
                git branch: 'main',
                credentialsId: 'git-cred',
                url: 'https://github.com/CloudHight/13-NOVEMBER-Sock-Shop-Kubernetes-Project-Using-Ansible-EU-Team-2.git'
            }
        }
        stage('terraform init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('terraform fmt') {
            steps {
                sh 'terraform fmt'
            }
        }
        stage('terraform validate') {
            steps {
                sh 'terraform validate'
            }
        }
        stage('terraform plan') {
            steps {
                sh 'terraform plan'
            }
        }
        stage('Request Approval to apply') {
            steps {
                timeout(activity: true, time: 5) {
                    input message: 'Needs Approval to Apply ', submitter: 'admin'
                }
            }
        }
        stage('terraform action') {
            steps {
                sh 'terraform ${action} -auto-approve'
            }
        }
    }
}
