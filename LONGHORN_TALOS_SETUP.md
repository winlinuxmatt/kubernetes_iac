# Longhorn on Talos Linux - Setup Guide

## Prerequisites

### Talos Worker Node Configuration

**IMPORTANT**: Worker nodes must have kubelet extraMounts configured for Longhorn to work properly. This is already configured in `cluster.tf` for all worker nodes:

```hcl
config_patches = [
  yamlencode({
    machine = {
      kubelet = {
        extraMounts = [
          {
            destination = "/var/lib/longhorn"
            type        = "bind"
            source      = "/var/lib/longhorn"
            options     = ["bind", "rshared", "rw"]
          }
        ]
      }
    }
  })
]
```

After applying Terraform changes to worker configurations, **reboot the worker nodes** for kubelet changes to take effect:

```bash
talosctl reboot --nodes 10.0.0.73
talosctl reboot --nodes 10.0.0.74
talosctl reboot --nodes 10.0.0.75
```

## Quick Installation

Use the provided installation script for a complete setup:

```bash
./longhorn-install.sh
```

This script will:
1. Create the `longhorn-system` namespace with proper pod security labels
2. Install Longhorn via Helm
3. Expose the UI on NodePort 30080
4. Configure storage disks on all worker nodes

## Manual Installation

### Step 1: Create Namespace

```bash
kubectl create namespace longhorn-system
kubectl label namespace longhorn-system \
    pod-security.kubernetes.io/enforce=privileged \
    pod-security.kubernetes.io/audit=privileged \
    pod-security.kubernetes.io/warn=privileged
```

### Step 2: Install Longhorn

```bash
helm repo add longhorn https://charts.longhorn.io
helm repo update
helm install longhorn longhorn/longhorn \
    --namespace longhorn-system \
    --set defaultSettings.createDefaultDiskLabeledNodes=true \
    --set persistence.defaultClassReplicaCount=3
```

### Step 3: Expose UI

```bash
kubectl patch svc longhorn-frontend -n longhorn-system \
    -p '{"spec": {"type": "NodePort", "ports": [{"port": 80, "targetPort": 8000, "nodePort": 30080}]}}'
```

### Step 4: Configure Storage Disks

```bash
# For each worker node
kubectl patch nodes.longhorn.io talos-worker-01 -n longhorn-system --type='merge' \
    -p '{"spec":{"disks":{"default-disk":{"path":"/var/lib/longhorn","allowScheduling":true,"storageReserved":0}}}}'

kubectl patch nodes.longhorn.io talos-worker-02 -n longhorn-system --type='merge' \
    -p '{"spec":{"disks":{"default-disk":{"path":"/var/lib/longhorn","allowScheduling":true,"storageReserved":0}}}}'

kubectl patch nodes.longhorn.io talos-worker-03 -n longhorn-system --type='merge' \
    -p '{"spec":{"disks":{"default-disk":{"path":"/var/lib/longhorn","allowScheduling":true,"storageReserved":0}}}}'
```

## Access

- **Longhorn UI**: http://<worker-node-ip>:30080
- **Worker IPs**: 10.0.0.73, 10.0.0.74, 10.0.0.75

## Verification

Check storage status:
```bash
kubectl get nodes.longhorn.io -n longhorn-system -o jsonpath='{range .items[*]}{.metadata.name}: {.status.diskStatus.default-disk.storageAvailable}{"\n"}{end}'
```

Check all pods are running:
```bash
kubectl get pods -n longhorn-system
```

## Talos-Specific Notes

### ✅ Safe to Ignore

1. **Kernel detection failures** - Talos doesn't have bash in nsenter containers
2. **OS detection failures** - Same reason as above
3. **iscsid service warnings** - Talos uses `ext-iscsid` instead of traditional `iscsid.service`

### ✅ Verified Working

- **iSCSI Support**: Talos includes `ext-iscsid` by default
- **Kernel Version**: 6.12.57-talos (exceeds minimum requirement of 5.8)
- **MountPropagation**: Enabled via kubelet extraMounts in Terraform

## Troubleshooting

If volumes fail to attach, verify:
- Worker nodes were rebooted after Terraform apply
- `ext-iscsid` is running: `talosctl services`
- Disks are configured: `kubectl get nodes.longhorn.io -n longhorn-system`
- CSI driver pods are healthy: `kubectl get pods -n longhorn-system`

## Uninstall

```bash
helm uninstall longhorn -n longhorn-system
kubectl delete ns longhorn-system
```
