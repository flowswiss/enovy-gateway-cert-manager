#!/bin/bash
# Install Gateway API CRDs
# Version: v1.3.0 (Latest stable)

echo "Installing Gateway API CRDs v1.3.0..."

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/experimental-install.yaml

echo "Gateway API CRDs installed successfully!"
echo ""
echo "Installed CRDs:"
kubectl get crd | grep gateway.networking.k8s.io
