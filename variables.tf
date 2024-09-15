variable "cluster_name" {
  type    = string
  default = "kubernetes_cluster"
}

variable "default_gateway" {
  type    = string
  default = "10.0.0.1"
}

variable "talos_cp_01_ip_addr" {
  type    = string
  default = "10.0.0.70"
}

variable "talos_cp_02_ip_addr" {
  type    = string
  default = "10.0.0.71"
}

variable "talos_cp_03_ip_addr" {
  type    = string
  default = "10.0.0.72"
}

variable "talos_worker_01_ip_addr" {
  type    = string
  default = "10.0.0.73"
}

variable "talos_worker_02_ip_addr" {
  type    = string
  default = "10.0.0.74"
}

variable "talos_worker_03_ip_addr" {
  type    = string
  default = "10.0.0.75"
}
