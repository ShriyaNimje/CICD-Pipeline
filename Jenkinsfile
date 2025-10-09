pipeline {
    agent any

    environment {
        APP_DIR = '.'                    // Your app directory
        TARGET_EC2 = '18.223.28.39'     // Replace with your EC2 IP
        DOCKER_USERNAME = 'your-docker-username'
        DOCKER_IMAGE = "${DOCKER_USERNAME}/python-app:latest"
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
                sh """
                    docker build -t python-app:latest ${APP_DIR}
                    docker tag python-app:latest ${DOCKER_IMAGE}
                """
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                echo "📤 Pushing Docker image to Docker Hub"
                withCredentials([string(credentialsId: 'docker-hub-token', variable: 'DOCKER_TOKEN')]) {
                    sh """
                        echo $DOCKER_TOKEN | docker login -u ${DOCKER_USERNAME} --password-stdin
                        docker push ${DOCKER_IMAGE}
                        docker logout
                    """
                }
            }
        }

        stage('Deploy on EC2') {
            steps {
                echo "🚀 Deploying app on EC2"
                sshagent(['ubuntu']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@${TARGET_EC2} '
                            docker login -u ${DOCKER_USERNAME} -p ${DOCKER_TOKEN} &&
                            docker pull ${DOCKER_IMAGE} &&
                            docker stop python-app || true &&
                            docker rm python-app || true &&
                            docker run -d --name python-app -p 5000:5000 ${DOCKER_IMAGE}
                        '
                    """
                }
            }
        }

        stage('Verify Application') {
            steps {
                echo "✅ Application deployed. You can verify on http://${TARGET_EC2}:5000"
            }
        }
    }

    post {
        failure {
            echo "❌ Pipeline failed. Check logs."
        }
        success {
            echo "🎉 Pipeline completed successfully!"
        }
    }
}
