#!/bin/bash
# harden-firewall.sh — UFW default-deny + explicit service allows
# Run ONCE. Only after Tailscale and SSH confirmed working.
set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

echo -e "${YELLOW}=== Mushishi Firewall Hardening ===${NC}"
read -p "Type 'mushishi' to confirm reset + harden UFW: " CONFIRM
[ "$CONFIRM" != "mushishi" ] && echo "Aborted." && exit 1

sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Detect Tailscale interface
TS_IP=$(ip addr show tailscale0 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d'/' -f1)

if [ -n "$TS_IP" ]; then
    echo -e "${GREEN}Tailscale detected ($TS_IP) — restricting all services to Tailscale interface.${NC}"
    # SSH via Tailscale only
    sudo ufw allow in on tailscale0 to any port 22 proto tcp comment 'SSH (Tailscale only)'
    # AI stack services
    sudo ufw allow in on tailscale0 to any port 8000 proto tcp comment 'Nemotron GPU NIM'
    sudo ufw allow in on tailscale0 to any port 8001 proto tcp comment 'Nemotron CPU llama.cpp'
    sudo ufw allow in on tailscale0 to any port 7860 proto tcp comment 'Hermes Agent'
    sudo ufw allow in on tailscale0 to any port 6006 proto tcp comment 'Arize Phoenix'
    sudo ufw allow in on tailscale0 to any port 19999 proto tcp comment 'Netdata'
    sudo ufw allow in on tailscale0 to any port 4000 proto tcp comment 'LiteLLM (Phase 5)'
    sudo ufw allow in on tailscale0 to any port 3000 proto tcp comment 'DeerFlow (Phase 5)'
    sudo ufw allow in on tailscale0 to any port 3100 proto tcp comment 'Paperclip (Phase 5.5)'
    # Audio stack (v1.7 addition)
    sudo ufw allow in on tailscale0 to any port 9000 proto tcp comment 'Audio Gateway (v1.7)'
    sudo ufw allow in on tailscale0 to any port 9010 proto tcp comment 'Audio rq-dashboard (v1.7)'
else
    echo -e "${YELLOW}Tailscale not detected — allowing SSH on all interfaces.${NC}"
    echo "Re-run this script after Tailscale is up to restrict SSH to Tailscale only."
    sudo ufw allow 22/tcp comment 'SSH (WARNING: all interfaces — re-run after Tailscale)'
    sudo ufw allow 8000/tcp comment 'Nemotron GPU NIM'
    sudo ufw allow 8001/tcp comment 'Nemotron CPU'
    sudo ufw allow 8642/tcp comment 'Hermes Agent'    sudo ufw allow in on tailscale0 to any port 8642 proto tcp comment 'Hermes gateway API (v1.6)'
    sudo ufw allow in on tailscale0 to any port 9119 proto tcp comment 'Hermes dashboard (v1.6)'
    sudo ufw allow 6006/tcp comment 'Arize Phoenix'
    sudo ufw allow 19999/tcp comment 'Netdata'
fi

# Tailscale coordination
sudo ufw allow 41641/udp comment 'Tailscale WireGuard'
# Docker inter-container
sudo ufw allow in on docker0 comment 'Docker internal'
sudo ufw logging on
sudo ufw --force enable

echo ""
echo -e "${GREEN}=== Firewall Active ===${NC}"
sudo ufw status verbose
echo ""
echo "Verify from Mac:"
echo "  ssh mushi@mushishi 'echo OK'           # should work"
echo "  curl http://mushishi:8000/v1/models    # should work (after Phase 1)"
