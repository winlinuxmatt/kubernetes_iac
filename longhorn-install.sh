#!/bin/bash
# Longhorn Installation Script for Talos Kubernetes Cluster
# This script installs Longhorn and configures storage on all worker nodes

set -e

echo "=== Longhorn Installation for Talos ==="

# Check prerequisites
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed"
    exit 1
fi

if ! command -v helm &> /dev/null; then
    echo "Error: helm is not installed"
    exit 1
fi

# Add Longhorn Helm repo
echo "Adding Longhorn Helm repository..."
helm repo add longhorn https://charts.longhorn.io 2>/dev/null || true
helm repo update

# Create namespace with pod security labels
echo "Creating longhorn-system namespace..."
kubectl create namespace longhorn-system 2>/dev/null || true
kubectl label namespace longhorn-system \
    pod-security.kubernetes.io/enforce=privileged \
    pod-security.kubernetes.io/audit=privileged \
    pod-security.kubernetes.io/warn=privileged \
    --overwrite

# Install Longhorn
echo "Installing Longhorn..."
helm upgrade --install longhorn longhorn/longhorn \
    --namespace longhorn-system \
    --set defaultSettings.createDefaultDiskLabeledNodes=true \
    --set persistence.defaultClassReplicaCount=3 \
    --wait --timeout 5m

# Wait for Longhorn manager pods to be ready
echo "Waiting for Longhorn manager pods..."
kubectl wait --for=condition=ready pod -l app=longhorn-manager -n longhorn-system --timeout=300s

# Expose Longhorn UI via NodePort
echo "Exposing Longhorn UI on NodePort 30080..."
kubectl patch svc longhorn-frontend -n longhorn-system \
    -p '{"spec": {"type": "NodePort", "ports": [{"port": 80, "targetPort": 8000, "nodePort": 30080}]}}'

# Get worker nodes
WORKER_NODES=$(kubectl get nodes --no-headers -o custom-columns=":metadata.name" | grep worker)

# Configure disks on each worker node
echo "Configuring storage disks on worker nodes..."
for node in $WORKER_NODES; do
    echo "  Configuring disk on $node..."
    kubectl patch nodes.longhorn.io "$node" -n longhorn-system --type='merge' \
        -p '{"spec":{"disks":{"default-disk":{"path":"/var/lib/longhorn","allowScheduling":true,"storageReserved":0}}}}'
done

# Wait for disks to be ready
echo "Waiting for disks to initialize..."
sleep 10

# Verify disk status
echo ""
echo "=== Longhorn Storage Status ==="
for node in $WORKER_NODES; do
    STORAGE=$(kubectl get nodes.longhorn.io "$node" -n longhorn-system -o jsonpath='{.status.diskStatus.default-disk.storageAvailable}' 2>/dev/null || echo "0")
    STORAGE_GB=$((STORAGE / 1024 / 1024 / 1024))
    echo "  $node: ${STORAGE_GB} GB available"
done

echo ""
echo "=== Longhorn Installation Complete ==="
echo ""
echo "Longhorn UI available at:"
echo "  http://<worker-node-ip>:30080"
echo ""
echo "Worker node IPs:"
kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o wide --no-headers | awk '{print "  " $1 ": " $6}'
echo ""
echo "StorageClass 'longhorn' is now the default storage class."
