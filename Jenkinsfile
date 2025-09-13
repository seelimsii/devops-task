pipeline {
    agent any

    environment {
        // Get these values from 'terraform output'
        AWS_REGION       = 'ap-south-1'
        ECR_REPO_URL     = '167524899243.dkr.ecr.ap-south-1.amazonaws.com/devops-task-app' 
        EKS_CLUSTER_NAME = 'devops-task-cluster'
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    // Checkout code from the branch that triggered the pipeline
                    checkout scm
                }
            }
        }

        stage('Build & Test') {
            steps {
                script {
                    echo 'Installing dependencies and running tests...'
                    // Use a node container to keep the Jenkins agent clean
                    docker.image('node:18-alpine').inside {
                        dir('src') {
                            sh 'npm install --cache .npm-cache'
                            
                        }
                    }
                }
            }
        }

        stage('Dockerize') {
            steps {
                script {
                    echo 'Building Docker image...'
                    def image = docker.build("${ECR_REPO_URL}:${env.BUILD_NUMBER}")
        
                    withAWS(credentials: 'aws-credentials', region: AWS_REGION) {
                        echo 'Authenticating Docker to ECR...'
                        sh """
                            aws ecr get-login-password --region ${AWS_REGION} \
                            | docker login --username AWS --password-stdin ${ECR_REPO_URL}
                        """
        
                        echo 'Pushing image to AWS ECR...'
                        sh "docker push ${ECR_REPO_URL}:${env.BUILD_NUMBER}"
                    }
                }
            }
        }


        stage('Deploy to EKS') {
            steps {
                script {
                    echo 'Deploying to EKS cluster...'
                    withAWS(credentials: 'aws-credentials', region: AWS_REGION) {
                        docker.image('amazon/aws-cli:latest').inside('--entrypoint=""') {
                            
                            echo 'Installing kubectl...'
                            
                            sh 'curl -L -s https://dl.k8s.io/release/stable.txt'
                            sh 'curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"'
                            sh 'chmod +x ./kubectl'
                            echo 'kubectl is ready to use.'
        
                            // --- THIS IS THE FIX ---
                            // Tell aws-cli to write the kubeconfig to a local, writable file
                            sh "aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_REGION} --kubeconfig ./kubeconfig"
        
                            // Replace the image placeholder
                            def imageUrl = "${ECR_REPO_URL}:${env.BUILD_NUMBER}"
                            sh "sed -i 's|__IMAGE_URL__|${imageUrl}|g' k8s/deployment.yaml"
        
                            // Apply the Kubernetes manifests using the local kubectl
                             sh "./kubectl --kubeconfig ./kubeconfig apply -f k8s/"
                            
                            echo "Deployment successful!"
                        }
                    }
                }
            }
        }
      }

    

    post {
        always {
            cleanWs() // Clean up the workspace
        }
    }

}













