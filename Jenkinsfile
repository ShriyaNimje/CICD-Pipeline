pipeline {
    agent any

    environment {
        IMAGE_NAME = "python-app:latest"
        APP_PORT = 5000
        APP_DIR = "."          // Python-app folder (Jenkinsfile is here)
        TARGET_EC2 = "18.223.28.39"  // Replace with your EC2 public IP
        SSH_CREDENTIALS = "ec2-ssh-key"   // Jenkins SSH credentials ID
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
                dir("${APP_DIR}") {
                    sh "docker build -t ${IMAGE_NAME} ."
                }
            }
        }

        stage('Push App Files to EC2') {
            steps {
                echo "📦 Copying app files to EC2"
                sshagent([env.SSH_CREDENTIALS]) {
                    sh """
                        scp -o StrictHostKeyChecking=no -r ${APP_DIR}/* ubuntu@${TARGET_EC2}:/home/ubuntu/app
                    """
                }
            }
        }

        stage('Deploy on EC2') {
            steps {
                echo "🚀 Deploying app on EC2"
                sshagent([env.SSH_CREDENTIALS]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@${TARGET_EC2} '
                            docker stop python-app || true
                            docker rm python-app || true
                            docker run -d --name python-app -p ${APP_PORT}:${APP_PORT} ${IMAGE_NAME}
                        '
                    """
                }
            }
        }

        stage('Verify Application') {
            steps {
                echo "🔍 Verifying the app"
                sh "curl -f http://${TARGET_EC2}:${APP_PORT} || (echo 'App not responding' && exit 1)"
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check logs.'
        }
    }
}
