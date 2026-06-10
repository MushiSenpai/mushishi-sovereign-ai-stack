#!/bin/bash
# harden-docker-firewall.sh — Close the Docker/UFW bypass (v1.8)
#
# PROBLEM: Docker inserts its own iptables NAT/FORWARD rules AHEAD of UFW.
# Every compose service published as "PORT:PORT" binds 0.0.0.0 and is
# reachable from the LAN (anyone on the Wi-Fi) regardless of UFW rules.
# Verified 2026-06-10: ComfyUI :8188 (no auth), LiteLLM :4000, DeerFlow :2026,
# Phoenix :6006/:4318, audio gateway :9000, rq-dashboard :9010, vLLM :8000.
#
# FIX: Append a DOCKER-USER chain policy to /etc/ufw/after.rules (the
# standard ufw-docker pattern). DOCKER-USER is evaluated BEFORE Docker's
# own accept rules for all forwarded (container-bound) traffic:
#   - tailscale0  -> allowed (Mac, future VPS)
#   - established -> allowed (replies to container-initiated outbound)
#   - docker bridges -> allowed (container-to-container)
#   - everything else (LAN/Wi-Fi, internet) -> DROP
#
# Host-published services (llama.cpp :8001, Hermes :8642) are NOT affected —
# they are governed by normal UFW rules, which are already tailscale-only.
#
# Run with: sudo bash /data/ai/01-workspace/scripts/harden-docker-firewall.sh
set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

[ "$EUID" -ne 0 ] && echo -e "${RED}Run with sudo.${NC}" && exit 1

AFTER_RULES="/etc/ufw/after.rules"
MARKER="MUSHISHI DOCKER-USER"

echo -e "${YELLOW}=== Docker firewall hardening ===${NC}"

# 1. Backup
BACKUP="${AFTER_RULES}.bak-$(date +%Y%m%d-%H%M%S)"
cp "$AFTER_RULES" "$BACKUP"
echo "Backed up after.rules -> $BACKUP"

# 2. Append DOCKER-USER block (idempotent)
if grep -q "$MARKER" "$AFTER_RULES"; then
  echo "DOCKER-USER block already present — skipping append."
else
  cat >> "$AFTER_RULES" << 'EOF'

# BEGIN MUSHISHI DOCKER-USER (v1.8) — block LAN access to Docker-published ports
*filter
:DOCKER-USER - [0:0]
# Tailnet devices (Mac, future VPS) may reach containers
-A DOCKER-USER -i tailscale0 -j RETURN
# Replies to connections containers initiated (apt, pip, model downloads)
-A DOCKER-USER -m conntrack --ctstate ESTABLISHED,RELATED -j RETURN
# Container-to-container traffic on docker bridges
-A DOCKER-USER -i docker0 -j RETURN
-A DOCKER-USER -i br-+ -j RETURN
# Everything else (LAN Wi-Fi clients, internet) is dropped
-A DOCKER-USER -j DROP
COMMIT
# END MUSHISHI DOCKER-USER
EOF
  echo "DOCKER-USER block appended."
fi

# 3. Tailscale-side UFW allows for audio ports (from audio stack doc — may
#    never have been applied; duplicates are skipped by ufw automatically)
ufw allow in on tailscale0 to any port 9000 proto tcp comment 'Audio Gateway (v1.7)' >/dev/null
ufw allow in on tailscale0 to any port 9010 proto tcp comment 'Audio rq-dashboard (v1.7)' >/dev/null
ufw allow in on tailscale0 to any port 8188 proto tcp comment 'ComfyUI (tailnet only)' >/dev/null
echo "UFW tailscale0 allows ensured (9000, 9010, 8188)."

# 4. Flush any stale DOCKER-USER rules, then reload ufw to apply the block
iptables -F DOCKER-USER 2>/dev/null || true
ufw reload
echo ""
echo -e "${GREEN}=== Applied. Current DOCKER-USER chain: ===${NC}"
iptables -L DOCKER-USER -v --line-numbers

echo ""
echo -e "${YELLOW}VERIFY (do all three):${NC}"
echo "  1. From Mac over Tailscale:  curl -s http://mushishi:8188 | head -1   # should WORK"
echo "  2. From a phone on the Wi-Fi (NOT on Tailscale):"
echo "     open http://$(hostname -I | awk '{print $1}'):8188                 # should TIME OUT"
echo "  3. Containers still have internet:"
echo "     docker exec litellm-proxy python3 -c 'import urllib.request; print(urllib.request.urlopen(\"https://api.groq.com\", timeout=5).status)' 2>&1 | tail -1"
echo ""
echo -e "${YELLOW}ROLLBACK if anything breaks:${NC}"
echo "  sudo cp $BACKUP $AFTER_RULES && sudo ufw reload && sudo systemctl restart docker"
