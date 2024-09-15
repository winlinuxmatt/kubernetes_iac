# kubernetes_iac
Terraform Kubernetes IAC
# This was built following the following and altered to suppot my cluster setup. I do plan to omprove this over time, but this is the first interation of this
https://olav.ninja/talos-cluster-on-proxmox-with-terraform
by Olav

# I notice that there were a few thing needed after setting up the cluster and if anyone may want to see this it might help.

# To connect to your Talos Kubernetes cluster using the outputs from Terraform, you need to set up your local environment with the correct configuration files. Here's a step-by-step guide on how to use the kubeconfig and talosconfig outputs:

# Save the kubeconfig and talosconfig Outputs to Files

# First, you need to capture the output from Terraform and save them into files on your local machine. Run the following commands:

```
terraform output -raw kubeconfig > ~/.kube/config && terraform output -raw talosconfig > ~/.talos/config
```

# This assumes you have ~/.kube/config and ~/.talos/config as the default locations for Kubernetes and Talos configurations. Adjust the file paths if necessary.

# Verify File Permissions

# Ensure the permissions for these files are set correctly to avoid any security issues:

```
chmod 600 ~/.kube/config && chmod 600 ~/.talos/config
```

# Set Up kubectl

# Get the list of nodes

```
kubectl get nodes
NAME              STATUS   ROLES           AGE     VERSION
talos-cp-01       Ready    control-plane   3h39m   v1.30.0
talos-cp-02       Ready    control-plane   3h24m   v1.30.0
talos-cp-03       Ready    control-plane   3h24m   v1.30.0
talos-worker-01   Ready    <none>          3h39m   v1.30.0
talos-worker-02   Ready    <none>          3h24m   v1.30.0
talos-worker-03   Ready    <none>          3h24m   v1.30.0
```