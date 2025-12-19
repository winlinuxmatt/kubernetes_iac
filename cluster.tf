# Talos Cluster Configuration on Proxmox

# Talos Machine Secrets
resource "talos_machine_secrets" "machine_secrets" {}

# Talos Client Configuration
data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = [var.talos_cp_01_ip_addr]
}

# Control Plane Machine Configurations
data "talos_machine_configuration" "machineconfig_cp" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${var.talos_cp_01_ip_addr}:6443"
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.machine_secrets.machine_secrets
  kubernetes_version = var.kubernetes_version
}

data "talos_machine_configuration" "machineconfig_cp_02" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${var.talos_cp_02_ip_addr}:6443"
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.machine_secrets.machine_secrets
  kubernetes_version = var.kubernetes_version
}

data "talos_machine_configuration" "machineconfig_cp_03" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${var.talos_cp_03_ip_addr}:6443"
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.machine_secrets.machine_secrets
  kubernetes_version = var.kubernetes_version
}

# Apply Control Plane Configurations
resource "talos_machine_configuration_apply" "cp_config_apply" {
  depends_on                  = [proxmox_virtual_environment_vm.talos_cp_01]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_cp.machine_configuration
  node                        = var.talos_cp_01_ip_addr
  config_patches = [
    templatefile("./templates/cpnetwork.yaml.tmpl", { cpip = var.cp_vip })
  ]
}

resource "talos_machine_configuration_apply" "cp_config_apply_02" {
  depends_on                  = [proxmox_virtual_environment_vm.talos_cp_02]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_cp_02.machine_configuration
  node                        = var.talos_cp_02_ip_addr
  config_patches = [
    templatefile("./templates/cpnetwork.yaml.tmpl", { cpip = var.cp_vip })
  ]
}

resource "talos_machine_configuration_apply" "cp_config_apply_03" {
  depends_on                  = [proxmox_virtual_environment_vm.talos_cp_03]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_cp_03.machine_configuration
  node                        = var.talos_cp_03_ip_addr
  config_patches = [
    templatefile("./templates/cpnetwork.yaml.tmpl", { cpip = var.cp_vip })
  ]
}

# Worker Machine Configurations
data "talos_machine_configuration" "machineconfig_worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.talos_cp_01_ip_addr}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

data "talos_machine_configuration" "machineconfig_worker_02" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.talos_cp_02_ip_addr}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

data "talos_machine_configuration" "machineconfig_worker_03" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.talos_cp_03_ip_addr}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

# Apply Worker Configurations
resource "talos_machine_configuration_apply" "worker_config_apply" {
  depends_on                  = [proxmox_virtual_environment_vm.talos_worker_01]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_worker.machine_configuration
  node                        = var.talos_worker_01_ip_addr
  config_patches = [
    templatefile("./templates/worker-disks.yaml.tmpl", {})
  ]
}

resource "talos_machine_configuration_apply" "worker_config_apply_02" {
  depends_on                  = [proxmox_virtual_environment_vm.talos_worker_02]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_worker_02.machine_configuration
  node                        = var.talos_worker_02_ip_addr
  config_patches = [
    templatefile("./templates/worker-disks.yaml.tmpl", {})
  ]
}

resource "talos_machine_configuration_apply" "worker_config_apply_03" {
  depends_on                  = [proxmox_virtual_environment_vm.talos_worker_03]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_worker_03.machine_configuration
  node                        = var.talos_worker_03_ip_addr
  config_patches = [
    templatefile("./templates/worker-disks.yaml.tmpl", {})
  ]
}

# Bootstrap Control Plane
resource "talos_machine_bootstrap" "bootstrap" {
  depends_on           = [talos_machine_configuration_apply.cp_config_apply]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = var.talos_cp_01_ip_addr
}

# Cluster Health Check
data "talos_cluster_health" "health" {
  depends_on = [
    talos_machine_configuration_apply.cp_config_apply,
    talos_machine_configuration_apply.cp_config_apply_02,
    talos_machine_configuration_apply.cp_config_apply_03,
    talos_machine_configuration_apply.worker_config_apply,
    talos_machine_configuration_apply.worker_config_apply_02,
    talos_machine_configuration_apply.worker_config_apply_03
  ]
  client_configuration = data.talos_client_configuration.talosconfig.client_configuration
  control_plane_nodes = [
    var.talos_cp_01_ip_addr,
    var.talos_cp_02_ip_addr,
    var.talos_cp_03_ip_addr
  ]
  worker_nodes = [
    var.talos_worker_01_ip_addr,
    var.talos_worker_02_ip_addr,
    var.talos_worker_03_ip_addr
  ]
  endpoints = data.talos_client_configuration.talosconfig.endpoints
}

# Retrieve Kubeconfig
resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [talos_machine_bootstrap.bootstrap, data.talos_cluster_health.health]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = var.talos_cp_01_ip_addr
}

# Outputs
output "talosconfig" {
  value     = data.talos_client_configuration.talosconfig.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}

# Custom Script for Configuration
resource "null_resource" "run_custom_script" {
  provisioner "local-exec" {
    command = <<EOT
      mkdir -p ~/.kube ~/.talos
      terraform output -raw kubeconfig > ~/.kube/config
      terraform output -raw talosconfig > ~/.talos/config
      chmod 600 ~/.kube/config ~/.talos/config
    EOT
  }

  triggers = {
    kubeconfig  = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
    talosconfig = data.talos_client_configuration.talosconfig.talos_config
    timestamp   = timestamp() # Ensure the resource always detects changes
  }

  depends_on = [
    talos_cluster_kubeconfig.kubeconfig,
    data.talos_client_configuration.talosconfig,
    data.talos_cluster_health.health
  ]
}
