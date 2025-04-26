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
                bat 'npm ci'
                bat 'npm test'
                bat 'npm run build'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-credentials', usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_TOKEN')]) {
                    bat """
                        docker login ghcr.io -u ${GITHUB_USER} -p ${GITHUB_TOKEN}
                        docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:${env.BUILD_NUMBER} .
                        docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest .
                    """
                }
            }
        }
        
        stage('Pubat Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-credentials', usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_TOKEN')]) {
                    bat """
                        docker pubat ${DOCKER_REGISTRY}/${IMAGE_NAME}:${env.BUILD_NUMBER}
                        docker pubat ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest
                    """
                }
            }
        }
        
        stage('Deploy to Docker Swarm') {
            steps {
                withCredentials([sbatUserPrivateKey(credentialsId: 'docker-swarm-credentials', keyFileVariable: 'Sbat_KEY')]) {
                    bat """
                        chmod 600 ${Sbat_KEY}
                        sbat -i ${Sbat_KEY} -o StrictHostKeyChecking=no root@${DOCKER_SWARM_HOST} \
                        'docker stack deploy -c docker-stack.yml realtime-editor'
                    """
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
            bat 'docker logout ghcr.io'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
} 