# Subnet Router

This script allows you to transform a regular Ubuntu Linux Container (LXC) into a Tailscale VPN endpoint [subnet router](https://tailscale.com/kb/1019/subnets) within a given network.

## Getting Started

Start by installing Git in the Linux Container:
`apt-get update && apt-get install git`

After this, we can pull down the script (either by using SSH keys or HTTPS). You will need to change the permissions on the `setup_env.sh` file using `chmod +x setup_env.sh` and you should be able to execute it afterwards using `./setup_env.sh`. After running this script, your container will be configured for becoming a VPN endpoint and it will produce an additional file called `start_vpn.sh`.

## Configurations

In the `/etc/sysctl.conf` file within the LXC container, you will need to change both IPV4 forwarding and IPV6 forwarding equal to 1 (default is 0). Afterwards, you will need to shutdown the container using `shutdown -h now` and move over to the Proxmox host shell. Navigate to `/etc/pve/lxc/<container_number>.conf` and add the following two lines to the end of the file:

```
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file
```

Afterwards, you can start the container and edit `./start_vpn.sh` to include the routes you would like to advertise. You can do this by replacing <routes> with your advertised subnets (i.e. 192.168.1.0/24 or 172.16.0.0/16). You can advertise multiple subnets by specifying a comma between the desired subnets. 

## Tailscale Operations

If this is the first time using LXC as a VPN endpoint, running `start_vpn.sh` will start the Tailscale VPN service and generate a unique link to add the LXC container as apart of your Tailnet. You can take this link and paste it in any browser on a machine where you are signed into Tailscale and it will simply allow you to add the LXC into the Tailnet. 

### Stopping Tailscale

To stop the VPN connection, simply issuing the `tailscale down` command will disconnect (not remove) the endpoint from the tailnet.

### Restarting Tailscale

To restart the VPN connection, you can either run `start_vpn.sh` or you can manually type `tailscale up --advertise-routes="<routes>" --accept-routes`.