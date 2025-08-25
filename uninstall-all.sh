#!/bin/bash
# Uninstall script to clean up everything

echo "=========================================="
echo "Uninstalling Envoy Gateway + cert-manager"
echo "=========================================="
echo ""

read -p "Are you sure you want to uninstall everything? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 1
fi

echo ""
echo "Removing test application..."
kubectl delete -f test-service.yaml --ignore-not-found=true

echo "Removing certificates..."
kubectl delete -f certificate.yaml --ignore-not-found=true

echo "Removing Let's Encrypt issuers..."
kubectl delete -f letsencrypt-issuers.yaml --ignore-not-found=true

echo "Removing Gateway resources..."
kubectl delete -f gateway-resources.yaml --ignore-not-found=true

echo "Uninstalling cert-manager..."
kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.yaml --ignore-not-found=true

echo "Uninstalling Envoy Gateway..."
helm uninstall eg -n envoy-gateway-system --ignore-not-found
kubectl delete namespace envoy-gateway-system --ignore-not-found=true

echo "Removing Gateway API CRDs..."
kubectl delete -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/experimental-install.yaml --ignore-not-found=true

echo ""
echo "Cleanup complete!"
