#!/bin/bash
apt-get install vim -y
apt-get remove openssh-server -y
ufw deny 22
apt update && apt upgrade -y
apt install curl -y
curl -fsSL https://tailscale.com/install.sh | sh
touch start_vpn.sh
echo "tailscale up --advertise-routes=<routes> --accept-routes" > start_vpn.sh
chmod +x start_vpn.sh