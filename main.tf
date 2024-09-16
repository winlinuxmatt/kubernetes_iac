# This Terraform configuration file is designed to manage a Talos cluster on Proxmox. It provides a structured approach to deploying and managing the cluster environment. The configuration includes the Proxmox provider, local variables for Talos version, and resources for downloading the Talos image and applying machine configurations for control plane and worker nodes. By utilizing data blocks for retrieving machine configurations, the configuration ensures that the correct settings are applied to each node based on its role in the cluster. Additionally, the configuration includes dependencies to ensure that resources are created in the correct order. Overall, this Terraform configuration offers a modular and scalable solution for deploying and managing a Talos cluster on Proxmox, providing a seamless experience for cluster administrators.
provider "proxmox" {
  endpoint = "https://pve:8006/"
  insecure = true # Only needed if your Proxmox server is using a self-signed certificate
}
