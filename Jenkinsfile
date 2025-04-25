pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'ghcr.io'
        IMAGE_NAME = 'realtime-editor'
        DOCKER_SWARM_HOST = 'your-swarm-manager-ip'  // Replace with your actual swarm manager IP
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build and Test') {
            steps {
                sh 'npm ci'
                sh 'npm test'
                sh 'npm run build'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-credentials', usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_TOKEN')]) {
                    sh """
                        docker login ghcr.io -u ${GITHUB_USER} -p ${GITHUB_TOKEN}
                        docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:${env.BUILD_NUMBER} .
                        docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest .
                    """
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-credentials', usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_TOKEN')]) {
                    sh """
                        docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:${env.BUILD_NUMBER}
                        docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest
                    """
                }
            }
        }
        
        stage('Deploy to Docker Swarm') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'docker-swarm-credentials', keyFileVariable: 'SSH_KEY')]) {
                    sh """
                        chmod 600 ${SSH_KEY}
                        ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no root@${DOCKER_SWARM_HOST} \
                        'docker stack deploy -c docker-stack.yml realtime-editor'
                    """
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
            sh 'docker logout ghcr.io'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
} 