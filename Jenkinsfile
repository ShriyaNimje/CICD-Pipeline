pipeline {
    agent any

    environment {
        APP_DIR = '.'                    // Your app directory
        TARGET_EC2 = '18.223.28.39'     // Your EC2 public IP
        SSH_CREDENTIALS = 'ec2-ssh-key' // Jenkins credential ID for your EC2 private key
        DOCKER_USERNAME = 'shriya01'    // Docker Hub username
        DOCKER_IMAGE = "${DOCKER_USERNAME}/python-app:latest"
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo "Checking out code from GitHub"
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image"
                sh """
                    docker build -t python-app:latest ${APP_DIR}
                    docker tag python-app:latest ${DOCKER_IMAGE}
                """
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                echo "Pushing Docker image to Docker Hub"
                withCredentials([string(credentialsId: 'docker-hub-token', variable: 'DOCKER_TOKEN')]) {
                    sh """
                        echo "Logging in to Docker Hub..."
                        echo \$DOCKER_TOKEN | docker login -u ${DOCKER_USERNAME} --password-stdin
                        docker push ${DOCKER_IMAGE}
                        docker logout
                    """
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                echo "Deploying Docker container to EC2"
                sshagent([SSH_CREDENTIALS]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@${TARGET_EC2} \\
                        'docker pull ${DOCKER_IMAGE} &&
                         docker stop python-app || true &&
                         docker rm python-app || true &&
                         docker run -d -p 5000:5000 --name python-app --restart unless-stopped ${DOCKER_IMAGE}'
                    """
                }
            }
        }

        stage('Verify Application') {
            steps {
                echo "Application deployed. Access it at http://${TARGET_EC2}:5000"
            }
        }
    }

    post {
        failure {
            echo "Pipeline failed. Check logs."
        }
        success {
            echo "Pipeline completed successfully!"
        }
    }
}
