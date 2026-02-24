🤖 Streamlit ChatBot Deployment on Kubernetes (Minikube)This repository contains a Streamlit-based chatbot powered by the Google Gemini API, containerized with Docker, and deployed on a local Kubernetes cluster using Minikube.🚀 Deployment ArchitectureFrontend/App: Streamlit (Python)Container Registry: Docker HubOrchestration: Kubernetes (Minikube)Secrets: Kubernetes Secrets for API Keys and Docker Registry credentials.🛠 PrerequisitesUbuntu 22.04+ (or similar Linux environment)Docker installed and runningMinikube and Kubectl installedA Google Gemini API Key📋 Step-by-Step Instructions1. Start the EnvironmentInitialize Minikube using the Docker driver with optimized resources:Bashminikube start --driver=docker --memory=2500mb --disk-size=20g
2. Prepare the Docker ImageBuild the image locally and push it to Docker Hub:Bash# Build
docker build -t jagadish1607/chatbot_k8s:v1 .

# Login & Push
docker login -u jagadish1607
docker push jagadish1607/chatbot_k8s:v1
3. Configure Kubernetes SecretsCreate the secrets required for the application and for pulling the image from a private/authenticated registry:Bash# App Secrets (Gemini API)
kubectl create secret generic chatbot-secrets \
  --from-literal=GOOGLE_API_KEY='your-google-api-key'

# Docker Hub Credentials
kubectl create secret docker-registry regcred \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=jagadish1607 \
  --docker-password=your-dockerhub-token \
  --docker-email=your-email@example.com
4. Deploy to KubernetesApply the manifests. Note: Ensure Deployment.yaml has the correct indentation for env and ports.Bashkubectl apply -f Deployment.yaml
kubectl apply -f Service.yaml
5. Network Access (The Bridge)Since Minikube runs in an isolated network on your server, use port-forwarding to make it accessible:Bash# Run in background
nohup kubectl port-forward service/chatbot-service 8501:80 --address 0.0.0.0 > chatbot.log 2>&1 &
6. Domain Mapping (Optional)To map your GoDaddy domain to the app without using port 8501 in the URL:Point GoDaddy A Record to your EC2 Public IP.Redirect Port 80 to 8501 locally:Bashsudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8501
🔍 Troubleshooting & Useful CommandsGoalCommandCheck Pod Statuskubectl get podsView Live Logskubectl logs -f <pod-name>Check Events (Errors)kubectl describe pod <pod-name>Verify Image Presenceeval $(minikube docker-env) && docker imagesFull Cleanupminikube delete --all --purge && docker system prune -af