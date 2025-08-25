#!/bin/bash
# Deploy test application

echo "Deploying test application..."

# Apply test service
kubectl apply -f test-service.yaml

echo ""
echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=60s deployment/hello-world -n default

echo ""
echo "Test application status:"
kubectl get pods -l app=hello-world -n default
kubectl get svc hello-world-service -n default

echo ""
echo "Application is deployed!"
echo ""
echo "Access the application at:"
echo "  http://juhu.dev.k8s.cloudbit.ch"
echo "  https://juhu.dev.k8s.cloudbit.ch (after certificate is ready)"
