pipeline {
    agent any

    environment {
        IMAGE_NAME = "python-app:latest"
        APP_PORT   = 5000
        TF_DIR     = "terraform"   // Terraform folder inside Python-app
        APP_DIR    = "/home/ubuntu/python-app" // Remote folder on EC2
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo "🔹 Checking out code from GitHub"
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
                echo "🐳 Building Docker image"
                dir('.') {
                    sh 'docker build -t ${IMAGE_NAME} .'
                }
            }
        }

        stage('Push App Files to EC2') {
            steps {
                echo "📦 Copying app files to EC2"
                sshagent(['ubuntu']) { // Use your Jenkins SSH credential ID
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@18.223.28.39 'mkdir -p ${APP_DIR}'
                        scp -o StrictHostKeyChecking=no -r * ubuntu@18.223.28.39:${APP_DIR}/
                    """
                }
            }
        }

        stage('Deploy on EC2') {
            steps {
                echo "🚀 Deploying Docker container on EC2"
                sshagent(['ubuntu']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@18.223.28.39 '
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
                script {
                    echo "🔍 Verifying application"
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
