# This file defines the required providers for the Terraform configuration.
terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.65.0"
    }
    talos = {
      source = "siderolabs/talos"
      version = "0.5.0"
    }
  }
}
