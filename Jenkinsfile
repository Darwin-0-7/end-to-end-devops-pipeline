pipeline {
    agent any

    // Variables-a dynamic parameters aah maathiyachu
    parameters {
        string(name: 'DOCKER_HUB_USER', defaultValue: 'darwin0407', description: 'Enter your Docker Hub Username')
        string(name: 'APP_NAME', defaultValue: 'weather-tracker', description: 'Enter the Application Name')
        string(name: 'DOCKER_CRED_ID', defaultValue: 'Darwincr7', description: 'Enter Jenkins Credentials ID for Docker')
        string(name: 'GIT_REPO_URL', defaultValue: 'https://github.com/Darwin-0-7/end-to-end-devops-pipeline.git', description: 'Enter GitHub Repository URL')
    }

    environment {
        IMAGE_TAG = "${env.BUILD_NUMBER}" 
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Hardcoded URL-ku badhila parameter use pandrom
                git branch: 'main', url: "${params.GIT_REPO_URL}"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${params.DOCKER_HUB_USER}/${params.APP_NAME}:${IMAGE_TAG} ."
                    sh "docker tag ${params.DOCKER_HUB_USER}/${params.APP_NAME}:${IMAGE_TAG} ${params.DOCKER_HUB_USER}/${params.APP_NAME}:latest"
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('', params.DOCKER_CRED_ID) {
                        sh "docker push ${params.DOCKER_HUB_USER}/${params.APP_NAME}:${IMAGE_TAG}"
                        sh "docker push ${params.DOCKER_HUB_USER}/${params.APP_NAME}:latest"
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
                            ssh -i \$SSH_KEY -o StrictHostKeyChecking=no ubuntu@\${EC2_SERVER_IP} "sudo docker pull ${params.DOCKER_HUB_USER}/${params.APP_NAME}:latest ; sudo docker stop weather-app || true ; sudo docker rm weather-app || true ; sudo docker run -d --name weather-app -p 5000:5000 -e WEATHER_API_KEY='\${API_KEY}' ${params.DOCKER_HUB_USER}/${params.APP_NAME}:latest"
                            """
                        }
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