locals {
  talos = {
    version = var.talos_version
  }
}

#
# **https://factory.talos.dev/?arch=amd64&cmdline-set=true&extensions=-&extensions=qemu-guest-agent&extensions=siderolabs%2Fiscsi-tools&extensions=siderolabs%2Futil-linux-tools&platform=nocloud&target=cloud&version=1.11.5**

# Or you can access it directly by schematic ID:

# **https://factory.talos.dev/schematics/e187c9b90f773cd8c84e5a3265c5554ee787b2fe67b508d9f955e90e7ae8c96c**

# This schematic includes:

# qemu-guest-agent (10.0.2)
# siderolabs/iscsi-tools (v0.2.0)
# siderolabs/util-linux-tools (2.41.1)
# For Talos version v1.11.5 on the nocloud platform (AMD64 architecture).

# curl -X POST --data-binary @- https://factory.talos.dev/schematics <<EOF
# customization:
#   systemExtensions:
#     officialExtensions:
#       - siderolabs/iscsi-tools
#       - siderolabs/util-linux-tools
#       - siderolabs/qemu-guest-agent
# EOF
#
# Press Enter to continue
#
# {"id":"e187c9b90f773cd8c84e5a3265c5554ee787b2fe67b508d9f955e90e7ae8c96c"}

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
