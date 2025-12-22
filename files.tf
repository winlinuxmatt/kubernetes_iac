locals {
  talos = {
    version = var.talos_version
  }
}

resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  content_type            = "iso"
  datastore_id            = "iso-template"
  node_name               = "pve"
  file_name               = "talos-${local.talos.version}-nocloud-amd64.img"
  url                     = "https://factory.talos.dev/image/e187c9b90f773cd8c84e5a3265c5554ee787b2fe67b508d9f955e90e7ae8c96c/${local.talos.version}/nocloud-amd64.raw.gz"
  decompression_algorithm = "gz"
  overwrite               = false

  lifecycle {
    create_before_destroy = false
  }
}
