# Subnet Router

Transform an Ubuntu Linux Container (LXC) into a Tailscale VPN endpoint with [subnet routing capabilities](https://tailscale.com/kb/1019/subnets).

## Getting Started

Start by installing Git in the Linux Container:
`apt-get update && apt-get install git`

After this, we can pull down the script (either by using SSH keys or HTTPS). After running this script, your container will be configured for becoming a VPN endpoint and it will produce an additional file called `start_vpn.sh`.

## Configurations

### LXC Shell

In the `/etc/sysctl.conf` file within the LXC container, you will need to uncomment both IPV4 packet forwarding & IPV6 packet forwarding to allow the packets to flow through the LXC and arrive at their intended destination. After saving the configuration, you will need to shutdown the container using `shutdown -h now` and migrate over to the Proxmox host shell for the next step.

### Proxmox Shell

Once you have the Proxmox shell open, you will need to open `/etc/pve/lxc/<LXC-ID>.conf` and append the following lines at the bottom of the configuration file:  

```
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file
```

Once saved, you can start the container again and edit `start_vpn.sh` file to include the routes you would like to advertise. You can do this by replacing <routes> with your advertised subnet (i.e. 192.168.1.0/24). You can advertise multiple subnets simultaneously by specifying a comma between the desired subnets (i.e. 192.168.1.0/24, 172.16.0.0/16, 10.20.30.0/24, etc).

## Tailscale Operations

If this is the first time using the LXC as a VPN endpoint, issuing the `./start_vpn.sh` command will start the Tailscale VPN service and generate a unique link to add the LXC as apart of your Tailnet. You can take this link and paste it in any browser on any machine where you are signed into Tailscale and it will simply allow you to add the LXC into the Tailnet. 

### Admin Console

Within the Tailscale [admin console](https://login.tailscale.com/admin/machines), you will see your LXC has been added to your tailnet. To activate the subnet routes within the admin console, you will need to navigate to the LXC's settings (3 dots), hit the 'Edit Route Settings' button, approve each of the desired subnets you'd like to advertise, and finally save the configuration.

### Stopping Tailscale

To stop the VPN connection, simply issuing the `tailscale down` command within the LXC shell will disconnect (not remove) the endpoint from the tailnet.

### Restarting Tailscale

To restart the VPN connection, you can either issue the `./start_vpn.sh` command or you can manually type `tailscale up --advertise-routes="<your-desired-subnets>" --accept-routes` within the LXC shell.