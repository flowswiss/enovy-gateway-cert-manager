# Envoy Gateway v2 with cert-manager
Complete, working configuration for Envoy Gateway with cert-manager and Let's Encrypt certificates using Gateway API.

## ✅ What Works

This configuration has been tested and works reliably with:
- **Gateway API v1.3.0** (Latest stable as of August 2025)
- **Envoy Gateway v1.5.0** (Latest stable as of August 2025) 
- **cert-manager v1.18.2** (Latest version with working `--enable-gateway-api` flag)
- **Let's Encrypt** HTTP-01 challenge via Gateway API
- **MetalLB** LoadBalancer with fixed IP assignment

Note: We use cert-manager v1.18.2 which is the latest version. The `--enable-gateway-api` flag works correctly in this version.

## 🚀 Quick Start

### Prerequisites
- Kubernetes cluster (tested with k0s v1.33.3)
- kubectl installed and configured
- helm installed
- MetalLB or other LoadBalancer provider configured

### Complete Installation

```bash
# Step 1: Install Gateway API CRDs
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/experimental-install.yaml

# Step 2: Install Envoy Gateway via Helm
helm repo add eg https://gateway.envoyproxy.io
helm repo update
helm upgrade --install eg eg/gateway \
  --namespace envoy-gateway-system \
  --create-namespace \
  --version v1.5.0 \
  --wait

# Step 3: Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.18.2/cert-manager.yaml

# Wait for cert-manager to be ready
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager -n cert-manager
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager-webhook -n cert-manager
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager-cainjector -n cert-manager

# Step 4: Enable Gateway API support in cert-manager
kubectl patch deployment cert-manager -n cert-manager --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/template/spec/containers/0/args",
    "value": [
      "--v=2",
      "--cluster-resource-namespace=$(POD_NAMESPACE)",
      "--leader-election-namespace=kube-system",
      "--acme-http01-solver-image=quay.io/jetstack/cert-manager-acmesolver:v1.18.2",
      "--max-concurrent-challenges=60",
      "--enable-gateway-api"
    ]
  }
]'

# Wait for cert-manager to restart
kubectl rollout status deployment/cert-manager -n cert-manager

# Step 5: Apply Gateway and HTTPRoute configurations
kubectl apply -f gateway-resources.yaml

# Step 6: Apply Let's Encrypt ClusterIssuers
kubectl apply -f letsencrypt-issuers.yaml

# Step 7: Create certificate
kubectl apply -f certificate.yaml

# Step 8: (Optional) Deploy test application
kubectl apply -f test-service.yaml
```

## 🔍 Verification

```bash
# Check Envoy Gateway
kubectl get pods -n envoy-gateway-system

# Check cert-manager
kubectl get pods -n cert-manager

# Check Gateway status
kubectl get gateway eg -n default

# Check Certificate status (wait 1-2 minutes for Let's Encrypt)
kubectl get certificate -n default
kubectl describe certificate juhu-tls-cert -n default

# Check LoadBalancer IP
kubectl get svc -n envoy-gateway-system | grep LoadBalancer

# If certificate is not ready, check challenges
kubectl get challenge -n default
kubectl describe challenge -n default
```

## 🔐 Certificate Management

### Using Staging (Testing)
The configuration starts with Let's Encrypt staging by default:

```yaml
issuerRef:
  name: letsencrypt-staging
```

### Switch to Production
Once everything works, switch to production certificates:

1. Edit `certificate.yaml`
2. Change issuer from `letsencrypt-staging` to `letsencrypt-prod`
3. Apply changes:
```bash
kubectl apply -f certificate.yaml
```

## 🐛 Troubleshooting

### Certificate not issuing?
```bash
# Check certificate status
kubectl describe certificate juhu-tls-cert -n default

# Check challenges
kubectl get challenge -n default
kubectl describe challenge -n default

# Check cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager
```

### Gateway not working?
```bash
# Check Gateway status
kubectl describe gateway eg -n default

# Check Envoy pods
kubectl get pods -n envoy-gateway-system

# Check HTTPRoutes
kubectl get httproute -n default
```

### Common Issues and Solutions

1. **"gateway api is not enabled"**
   - Solution: Already fixed in our configuration with `--enable-gateway-api`

2. **"No agent available"**
   - Solution: Network issue between nodes, check k0s configuration

3. **Certificate stuck in "False" state**
   - Check DNS is pointing to correct IP
   - Check firewall allows port 80
   - Check challenge: `kubectl describe challenge -n default`

## 🗑️ Uninstallation

Complete uninstallation commands:

```bash
# Remove test application
kubectl delete -f test-service.yaml --ignore-not-found=true

# Remove certificate
kubectl delete -f certificate.yaml --ignore-not-found=true

# Remove Let's Encrypt issuers
kubectl delete -f letsencrypt-issuers.yaml --ignore-not-found=true

# Remove Gateway resources
kubectl delete -f gateway-resources.yaml --ignore-not-found=true

# Uninstall cert-manager
kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.18.2/cert-manager.yaml --ignore-not-found=true

# Uninstall Envoy Gateway
helm uninstall eg -n envoy-gateway-system
kubectl delete namespace envoy-gateway-system --ignore-not-found=true

# Remove Gateway API CRDs
kubectl delete -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/experimental-install.yaml --ignore-not-found=true
```
s
## 📝 Important Notes

### Version Summary
| Component | Version | Status |
|-----------|---------|--------|
| **Gateway API** | v1.3.0 | Latest stable |
| **Envoy Gateway** | v1.5.0 | Latest stable |
| **cert-manager** | v1.18.2 | Latest with working `--enable-gateway-api` |

### Why Not Helm for cert-manager?
- Helm chart doesn't properly support Gateway API
- Missing RBAC permissions for Gateway API resources
- Feature gates don't work reliably
- kubectl installation with manual patching is more reliable

**Note:** Envoy Gateway uses Helm successfully - the issue is only with cert-manager's Gateway API support!

## 📚 References

- [Gateway API Documentation](https://gateway-api.sigs.k8s.io/)
- [Envoy Gateway Documentation](https://gateway.envoyproxy.io/)
- [cert-manager Documentation](https://cert-manager.io/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
---

**Last tested:** August 24, 2025  
**Cluster:** k0s v1.33.3  
**Environment:** 3-node cluster with Rook Ceph and MetalLB
