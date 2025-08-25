#!/bin/bash
# Install cert-manager with Gateway API support
# Version: v1.16.2 (Stable with working Gateway API)

echo "Installing cert-manager v1.16.2 with Gateway API support..."

# Install cert-manager with kubectl (more reliable than Helm for Gateway API)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.yaml

echo "Waiting for cert-manager to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager -n cert-manager
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager-webhook -n cert-manager
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager-cainjector -n cert-manager

echo ""
echo "Enabling Gateway API support..."

# Patch cert-manager deployment to enable Gateway API
kubectl patch deployment cert-manager -n cert-manager --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/template/spec/containers/0/args",
    "value": [
      "--v=2",
      "--cluster-resource-namespace=$(POD_NAMESPACE)",
      "--leader-election-namespace=kube-system",
      "--acme-http01-solver-image=quay.io/jetstack/cert-manager-acmesolver:v1.16.2",
      "--max-concurrent-challenges=60",
      "--enable-gateway-api"
    ]
  }
]'

echo "Waiting for cert-manager to restart with Gateway API support..."
kubectl rollout status deployment/cert-manager -n cert-manager

echo ""
echo "cert-manager installed successfully with Gateway API support!"
echo ""
echo "Checking installation:"
kubectl get pods -n cert-manager
