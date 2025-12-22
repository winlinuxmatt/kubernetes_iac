# Longhorn on Talos Linux - Setup Guide

## Environment Check Results

The Longhorn environment check script shows several warnings/errors that are **expected and safe to ignore** on Talos Linux:

### ✅ Safe to Ignore (Talos-specific)

1. **Kernel detection failures** - Talos doesn't have bash in nsenter containers
2. **OS detection failures** - Same reason as above
3. **iscsid service warnings** - Talos uses `ext-iscsid` instead of traditional `iscsid.service`

### ✅ Verified Working

All Talos worker nodes have `ext-iscsid` service running:
```bash
talosctl services | grep ext-iscsid
# ext-iscsid   Running
```

## Talos Configuration Requirements

Longhorn works on Talos with the following considerations:

1. **iSCSI Support**: Talos includes `ext-iscsid` by default (verified running)
2. **Kernel Version**: 6.12.57-talos (exceeds minimum requirement of 5.8)
3. **Storage**: Raw block devices available on worker nodes

## Installation

Install Longhorn using the provided values file:

```bash
helm repo add longhorn https://charts.longhorn.io
helm repo update
helm install longhorn longhorn/longhorn \
  --namespace longhorn-system \
  --create-namespace \
  --values longhorn-values.yaml
```

## Post-Installation

1. Access Longhorn UI via NodePort on port 30080
2. Manually add disks in the UI for each worker node
3. Verify volume provisioning works

## Troubleshooting

If volumes fail to attach, verify:
- `ext-iscsid` is running: `talosctl services`
- Disks are properly formatted and added in Longhorn UI
- CSI driver pods are healthy: `kubectl get pods -n longhorn-system`
