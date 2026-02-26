// Build and deploy the Chatbot application to Kubernetes
// This pipeline:
//   1. Checks out code from GitHub
//   2. Builds a Docker image
//   3. Authenticates to Docker Hub
//   4. Pushes the image to Docker Hub
//   5. Creates/updates Kubernetes secrets
//   6. Sends build status emails

pipeline {
    agent { label 'docker-node' }

    environment {
        DOCKER_IMAGE = "jagadish1607/chatbot_k8s:${GIT_COMMIT}"
        CONTAINER_NAME = "chatbot-container"
        EMAIL_RECIPIENTS = "jagadevopslearning@gmail.com"
    }

    stages {

        // Clone the repository from GitHub (main branch)
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/Jagadish0716/chat-bot.git', branch: 'main'
            }
        }

        // Build Docker image from Dockerfile using commit hash as tag
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        // Authenticate to Docker Hub using stored credentials
        // Credentials are securely retrieved from Jenkins and passed to docker login
        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
            }
        }

        // Push the built image to Docker Hub registry
        stage('Push Docker Image') {
            steps {
                sh 'docker push $DOCKER_IMAGE'
            }
        }

        // Store sensitive credentials in Kubernetes
        // Creates/updates a secret with the Google Gemini API key
        // This secret will be used by the chatbot pod to access the API
        stage('Create Kubernetes Secrets') {
            steps {
                    withCredentials([string(credentialsId: 'gemini-api-key', variable: 'GOOGLE_API_KEY')]) {
                    sh '''
                        kubectl create secret generic chatbot-secrets --from-literal=GOOGLE_API_KEY=$GOOGLE_API_KEY --dry-run=client -o yaml | kubectl apply -f -
                    '''
                }
                    withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]){
                    kubectl create secret docker-registry regcred \
                    --docker-server=https://index.docker.io/v1/ \
                    --docker-username=$DOCKER_USER \
                    --docker-password=$DOCKER_PASS \
                    --docker-email=jagadishv0716@gmail.com
                }

            }

        }
        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    # Apply Kubernetes manifests to deploy the chatbot application
                    kubectl apply -f k8s/Deployments.yaml
                    kubectl apply -f k8s/Service.yaml
                    # Optionally, you can add commands to verify the deployment status
                    kubectl rollout status deployment/chatbot-deployment
                    kubectl get pods -l app=chatbot
                    kubectl get svc chatbot-service
                '''
            }
    }

    post {
        // Notify on successful build completion
        success {
            emailext(
                subject: "✅ SUCCESS: ${env.JOB_NAME} [Build #${env.BUILD_NUMBER}]",
                body: """<h3>Build Succeeded!</h3>
                         <p><b>Job:</b> ${env.JOB_NAME}</p>
                         <p><b>Build:</b> #${env.BUILD_NUMBER}</p>
                         <p><b>URL:</b> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                         <p>Check the attached logs for deployment details.</p>""",
                to: "${EMAIL_RECIPIENTS}",
                attachLog: true,
                compressLog: true,
                mimeType: 'text/html'
            )
        }

        // Notify on build failure with error details
        failure {
            emailext(
                subject: "❌ FAILURE: ${env.JOB_NAME} [Build #${env.BUILD_NUMBER}]",
                body: """<h3>Build Failed!</h3>
                         <p><b>Job:</b> ${env.JOB_NAME}</p>
                         <p><b>Build:</b> #${env.BUILD_NUMBER}</p>
                         <p><b>URL:</b> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                         <p>The build log is attached to help you debug.</p>""",
                to: "${EMAIL_RECIPIENTS}",
                attachLog: true,
                compressLog: true,
                mimeType: 'text/html'
            )
        }
    }
}
