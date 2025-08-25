#!/bin/bash
# Install Envoy Gateway
# Version: v1.5.0 (Latest stable)

echo "Installing Envoy Gateway v1.5.0..."

# Add Helm repo
helm repo add eg https://gateway.envoyproxy.io
helm repo update

# Install Envoy Gateway
helm upgrade --install eg eg/gateway \
  --namespace envoy-gateway-system \
  --create-namespace \
  --version v1.5.0 \
  --wait

echo ""
echo "Envoy Gateway installed successfully!"
echo ""
echo "Checking installation:"
kubectl get pods -n envoy-gateway-system
