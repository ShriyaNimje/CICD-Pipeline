pipeline {
    agent any

    environment {
        IMAGE_NAME = "python-app:latest"
        APP_PORT = 5000
        DEPLOY_USER = "ubuntu"
        DEPLOY_HOST = "18.223.28.39"    // ✅ Replace with your EC2 public IP
        SSH_CREDENTIALS = "ec2-ssh-key" // ✅ Jenkins SSH credentials ID
        APP_DIR = "/home/ubuntu/app"    // App folder on target EC2
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo "🔹 Checking out code from GitHub"
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🐳 Building Docker image"
                sh 'docker build -t ${IMAGE_NAME} .'
            }
        }

        stage('Push Docker Image to Target EC2') {
            steps {
                echo "📦 Copying app files to EC2"
                sshagent (credentials: ["${SSH_CREDENTIALS}"]) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_HOST} '
                            mkdir -p ${APP_DIR}
                        '
                        scp -o StrictHostKeyChecking=no -r * ${DEPLOY_USER}@${DEPLOY_HOST}:${APP_DIR}/
                    '''
                }
            }
        }

        stage('Deploy on EC2') {
            steps {
                echo "🚀 Deploying Docker container on EC2"
                sshagent (credentials: ["${SSH_CREDENTIALS}"]) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_HOST} '
                            cd ${APP_DIR} &&
                            docker stop python-app || true &&
                            docker rm python-app || true &&
                            docker build -t ${IMAGE_NAME} . &&
                            docker run -d --name python-app -p ${APP_PORT}:${APP_PORT} ${IMAGE_NAME}
                        '
                    '''
                }
            }
        }

        stage('Verify Application') {
            steps {
                echo "🔍 Verifying the app is running"
                sh "curl -f http://${DEPLOY_HOST}:${APP_PORT} || (echo 'App not responding' && exit 1)"
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully and app deployed to EC2!'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for errors.'
        }
    }
}
