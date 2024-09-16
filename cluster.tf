# This resource creates a new Talos machine secrets resource. 
resource "talos_machine_secrets" "machine_secrets" {}

# This data block retrieves the client configuration for the Talos cluster.
data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = [var.talos_cp_01_ip_addr]
}

# This data block retrieves the machine configuration for the "cp_01" node from the Talos provider.
data "talos_machine_configuration" "machineconfig_cp" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.talos_cp_01_ip_addr}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

# This data block retrieves the machine configuration for the "cp_02" node from the Talos provider.
data "talos_machine_configuration" "machineconfig_cp_02" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.talos_cp_02_ip_addr}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

# This data block retrieves the machine configuration for the "cp_03" node from the Talos provider.
data "talos_machine_configuration" "machineconfig_cp_03" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.talos_cp_03_ip_addr}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

# This resource applies the machine configuration for the "cp_01" node.
resource "talos_machine_configuration_apply" "cp_config_apply" {
  depends_on                  = [ proxmox_virtual_environment_vm.talos_cp_01 ]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_cp.machine_configuration
  count                       = 1
  node                        = var.talos_cp_01_ip_addr
}

# This resource applies the machine configuration for the "cp_02" node.
resource "talos_machine_configuration_apply" "cp_config_apply_02" {
  depends_on                  = [ proxmox_virtual_environment_vm.talos_cp_02 ]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_cp_02.machine_configuration
  count                       = 1
  node                        = var.talos_cp_02_ip_addr
}

# This resource applies the machine configuration for the "cp_03" node.
resource "talos_machine_configuration_apply" "cp_config_apply_03" {
  depends_on                  = [ proxmox_virtual_environment_vm.talos_cp_03 ]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_cp_03.machine_configuration
  count                       = 1
  node                        = var.talos_cp_03_ip_addr
}

# This data block retrieves the machine configuration for the "worker" nodes from the Talos provider.
data "talos_machine_configuration" "machineconfig_worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.talos_cp_01_ip_addr}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

# This data block retrieves the machine configuration for the "worker_02" node from the Talos provider.
data "talos_machine_configuration" "machineconfig_worker_02" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.talos_cp_02_ip_addr}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

# This data block retrieves the machine configuration for the "worker_03" node from the Talos provider.
data "talos_machine_configuration" "machineconfig_worker_03" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.talos_cp_03_ip_addr}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

# This resource applies the machine configuration for the "worker_01" node.
resource "talos_machine_configuration_apply" "worker_config_apply" {
  depends_on                  = [ proxmox_virtual_environment_vm.talos_worker_01 ]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_worker.machine_configuration
  count                       = 1
  node                        = var.talos_worker_01_ip_addr
}

# This resource applies the machine configuration for the "worker_02" node.
resource "talos_machine_configuration_apply" "worker_config_apply_02" {
  depends_on                  = [ proxmox_virtual_environment_vm.talos_worker_02 ]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_worker_02.machine_configuration
  count                       = 1
  node                        = var.talos_worker_02_ip_addr
}

# This resource applies the machine configuration for the "worker_03" node.
resource "talos_machine_configuration_apply" "worker_config_apply_03" {
  depends_on                  = [ proxmox_virtual_environment_vm.talos_worker_03 ]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_worker_03.machine_configuration
  count                       = 1
  node                        = var.talos_worker_03_ip_addr
}

# This resource bootstraps the Talos control plane node.
resource "talos_machine_bootstrap" "bootstrap" {
  depends_on           = [ talos_machine_configuration_apply.cp_config_apply ]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = var.talos_cp_01_ip_addr
}

# # This data block retrieves the health status of the Talos cluster.
# data "talos_cluster_health" "health" {
#   depends_on           = [
#     talos_machine_configuration_apply.cp_config_apply,
#     talos_machine_configuration_apply.cp_config_apply_02,
#     talos_machine_configuration_apply.cp_config_apply_03,
#     talos_machine_configuration_apply.worker_config_apply,
#     talos_machine_configuration_apply.worker_config_apply_02,
#     talos_machine_configuration_apply.worker_config_apply_03
#   ]
#   client_configuration = data.talos_client_configuration.talosconfig.client_configuration
#   control_plane_nodes  = [
#     var.talos_cp_01_ip_addr,
#     var.talos_cp_02_ip_addr,
#     var.talos_cp_03_ip_addr
#   ]
#   worker_nodes         = [
#     var.talos_worker_01_ip_addr,
#     var.talos_worker_02_ip_addr,
#     var.talos_worker_03_ip_addr
#   ]
#   endpoints            = data.talos_client_configuration.talosconfig.endpoints
# }

# # This data block retrieves the kubeconfig for the Talos cluster.
# data "talos_cluster_kubeconfig" "kubeconfig" {
#   depends_on           = [ talos_machine_bootstrap.bootstrap, data.talos_cluster_health.health ]
#   client_configuration = talos_machine_secrets.machine_secrets.client_configuration
#   node                 = var.talos_cp_01_ip_addr
# }

# # Output the Talos configuration and kubeconfig.
# output "talosconfig" {
#   value = data.talos_client_configuration.talosconfig.talos_config
#   sensitive = true
# }

# # Output the kubeconfig for the Talos cluster.
# output "kubeconfig" {
#   value = data.talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
#   sensitive = true
# }