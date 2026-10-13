pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = 'darwin0407'
        APP_NAME = 'weather-tracker'
        IMAGE_TAG = "${env.BUILD_NUMBER}" 
        DOCKER_CREDENTIALS_ID = 'Darwincr7' 
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Darwin-0-7/end-to-end-devops-pipeline.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_HUB_USER}/${APP_NAME}:${IMAGE_TAG} ."
                    sh "docker tag ${DOCKER_HUB_USER}/${APP_NAME}:${IMAGE_TAG} ${DOCKER_HUB_USER}/${APP_NAME}:latest"
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('', DOCKER_CREDENTIALS_ID) {
                        sh "docker push ${DOCKER_HUB_USER}/${APP_NAME}:${IMAGE_TAG}"
                        sh "docker push ${DOCKER_HUB_USER}/${APP_NAME}:latest"
                    }
                }
            }
        }

        stage('Deploy to AWS EC2') {
            steps {
                script {
                    withCredentials([
                        sshUserPrivateKey(credentialsId: 'aws-ec2-key', keyFileVariable: 'SSH_KEY'),
                        string(credentialsId: 'EC2_SERVER_IP', variable: 'EC2_SERVER_IP'),
                        string(credentialsId: 'WEATHER_API_SECRET', variable: 'API_KEY')
                    ]) {
                        sh """
                        chmod 400 \$SSH_KEY
                        ssh -i \$SSH_KEY -o StrictHostKeyChecking=no ubuntu@\${EC2_SERVER_IP} "sudo docker pull \${DOCKER_HUB_USER}/\${APP_NAME}:latest ; sudo docker stop weather-app || true ; sudo docker rm weather-app || true ; sudo docker run -d --name weather-app -p 5000:5000 -e WEATHER_API_KEY='\${API_KEY}' \${DOCKER_HUB_USER}/\${APP_NAME}:latest"
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo "CI/CD Pipeline Complete! The new version is live on AWS."
        }
        failure {
            echo "Pipeline failed. Check the Console Output in Jenkins."
        }
    }
}