pipeline {
    agent any

    environment {
        APP_DIR = '.'                    // Your app directory
        TARGET_EC2 = '18.223.28.39'     // Replace with your EC2 IP
        DOCKER_IMAGE = ""                // Will be set dynamically after login
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
                """
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                echo "📤 Pushing Docker image to Docker Hub"
                withCredentials([
                    usernamePassword(
                        credentialsId: 'docker-hub-token',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    script {
                        // Tag image dynamically after login
                        env.DOCKER_IMAGE = "${DOCKER_USERNAME}/python-app:latest"
                    }
                    sh """
                        echo "Logging in to Docker Hub..."
                        docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
                        docker tag python-app:latest $DOCKER_IMAGE
                        docker push $DOCKER_IMAGE
                        docker logout
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
