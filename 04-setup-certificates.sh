#!/bin/bash
# Setup Let's Encrypt issuers and certificates

echo "Setting up Let's Encrypt issuers..."

# Apply ClusterIssuers
kubectl apply -f letsencrypt-issuers.yaml

echo ""
echo "Waiting for issuers to be ready..."
sleep 5

echo ""
echo "ClusterIssuers status:"
kubectl get clusterissuer

echo ""
echo "Creating certificate for juhu.dev.k8s.cloudbit.ch..."

# Apply certificate
kubectl apply -f certificate.yaml

echo ""
echo "Waiting for certificate to be issued (this may take 1-2 minutes)..."
sleep 30

echo ""
echo "Certificate status:"
kubectl get certificate -n default

echo ""
echo "Checking challenge status:"
kubectl get challenge -n default

echo ""
echo "If certificate is not ready, check with:"
echo "  kubectl describe certificate juhu-tls-cert -n default"
echo "  kubectl describe challenge -n default"
