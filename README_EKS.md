# EKS Deployment Notes

Quick steps to deploy the chat-bot to AWS EKS from this repo:

1. Build and push image to ECR

```bash
# from repo root
./bash-scripts/push_to_ecr.sh us-west-2 my-chat-bot
```

2. Create a Kubernetes secret for `GOOGLE_API_KEY` in the target namespace:

```bash
kubectl create secret generic chatbot-secrets --from-literal=GOOGLE_API_KEY="<your-key>" -n <namespace>
```

3. (Optional) Create an imagePullSecret if your cluster nodes cannot pull from ECR directly.

4. Install AWS Load Balancer Controller and cert-manager in your cluster.

5. Update `k8s/eks/deployment.yaml` image field with your ECR URI and replace placeholders:

- `<aws_account_id>`
- `<region>`
- `<IRSA_ROLE_ARN>` (if using IRSA)

6. Apply manifests:

```bash
kubectl apply -f k8s/eks/serviceaccount-iam.yaml
kubectl apply -f k8s/eks/deployment.yaml
kubectl apply -f k8s/eks/service.yaml
kubectl apply -f k8s/eks/ingress.yaml
kubectl apply -f k8s/eks/pvc.yaml
```

7. Configure DNS/Route53 to point to the ALB (if using Ingress)

Notes:
- Replace `storageClassName` in `pvc.yaml` with your cluster's StorageClass if different.
- If you prefer a `LoadBalancer` Service instead of ALB+Ingress, change `service.yaml` to `type: LoadBalancer`.
- For secure access to Google APIs from pods, prefer using AWS Secrets Manager with IRSA and the AWS SDK or a secret-sync controller.
