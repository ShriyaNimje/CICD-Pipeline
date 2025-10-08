pipeline {
    agent any

    environment {
        IMAGE_NAME = "python-app:latest"
        APP_PORT = 5000
        TF_DIR = "terraform"  // Terraform folder inside Python-app
        APP_DIR = "."          // Python-app folder (Jenkinsfile is here)
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                dir("${APP_DIR}") {
                    sh 'docker build -t ${IMAGE_NAME} .'
                }
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
                script {
                    // Get EC2 public IP from Terraform output
                    def ec2_ip = sh(script: "cd ${TF_DIR} && terraform output -raw ec2_public_ip", returnStdout: true).trim()
                    echo "EC2 Public IP: ${ec2_ip}"

                    // Verify app is running
                    sh "curl -f http://${ec2_ip}:${APP_PORT} || (echo 'App not responding' && exit 1)"
                }
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
