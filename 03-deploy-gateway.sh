#!/bin/bash
# Deploy Gateway and Routes

echo "Deploying Gateway resources..."

# Apply Gateway and HTTPRoutes
kubectl apply -f gateway-resources.yaml

echo ""
echo "Waiting for Gateway to be ready..."
sleep 10

echo ""
echo "Gateway status:"
kubectl get gateway eg -n default

echo ""
echo "LoadBalancer IP:"
kubectl get svc -n envoy-gateway-system | grep LoadBalancer
