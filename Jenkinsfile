pipeline {
    agent any

    environment {
        IMAGE_NAME = "python-app:latest"
        APP_PORT = 5000
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${IMAGE_NAME} .'
            }
        }

        stage('Stop & Remove Old Container') {
            steps {
                sh 'docker stop python-app || true'
                sh 'docker rm python-app || true'
            }
        }

        stage('Run Container') {
            steps {
                sh "docker run -d --name python-app -p ${APP_PORT}:${APP_PORT} ${IMAGE_NAME}"
            }
        }

        stage('Verify Application') {
            steps {
                sh 'sleep 2'
                sh 'curl -f http://localhost:5000 || (echo "App not responding" && exit 1)'
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
