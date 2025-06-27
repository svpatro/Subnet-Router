provider "proxmox" {
  pm_api_url      = "https://<Proxmox-IP>:8006/api2/json"
  pm_user         = "username@pam"
  pm_password     = "Proxmox-Password"
  pm_tls_insecure = true
}

resource "proxmox_lxc" "my_container" {
  target_node  = "pve"  # your Proxmox node name
  hostname     = "TestContainer"
  ostemplate   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  password     = "ContainerPassword"

  cores        = 1
  memory       = 512
  swap         = 512
  start        = true

  network {
    name   = "eth0"
    bridge = "vmbr1"
    ip     = "dhcp"
    type   = "veth"
  }

  rootfs {
    storage = "local-lvm"
    size = "8G"
  }

  features {
    nesting = true
  }
}