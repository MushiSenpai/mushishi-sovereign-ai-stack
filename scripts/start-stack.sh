#!/bin/bash
# start-stack.sh — Bring up full AI stack after reboot
# Order: Phoenix → LiteLLM+Postgres → Netdata → CPU Nemotron
# GPU Nemotron (vLLM) started separately via agent-mode.sh or forensic-mode.sh
set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

LITELLM_DIR="/data/ai/06-configs/litellm"
PHOENIX_DIR="/data/ai/06-configs/phoenix"

# 1. Phoenix (OTEL tracing UI)
echo -e "${YELLOW}Starting Arize Phoenix...${NC}"
if docker ps --format '{{.Names}}' | grep -q "arize-phoenix"; then
  echo -e "${GREEN}  Phoenix already running.${NC}"
else
  docker compose -f "$PHOENIX_DIR/docker-compose.yml" up -d
  sleep 3
fi

# 2. LiteLLM + Postgres
echo -e "${YELLOW}Starting LiteLLM proxy + Postgres...${NC}"
if docker ps --format '{{.Names}}' | grep -q "litellm-proxy"; then
  echo -e "${GREEN}  LiteLLM already running.${NC}"
else
  docker compose -f "$LITELLM_DIR/docker-compose.yml" --env-file "$LITELLM_DIR/run.env" up -d
  sleep 5
  # Verify
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:4000/health/liveliness 2>/dev/null || echo "000")
  if [ "$STATUS" = "200" ]; then
    echo -e "${GREEN}  LiteLLM healthy (:4000).${NC}"
  else
    echo -e "${RED}  LiteLLM not responding (HTTP $STATUS) — check: docker logs litellm-proxy${NC}"
  fi
fi

# 3. Netdata (monitoring)
echo -e "${YELLOW}Checking Netdata...${NC}"
if docker ps --format '{{.Names}}' | grep -q "netdata"; then
  echo -e "${GREEN}  Netdata already running.${NC}"
else
  echo -e "${YELLOW}  Netdata not running. Start with:${NC}"
  echo "  docker start netdata   # or re-run the original docker run command"
fi

# 4. CPU Nemotron (PRISM floor)
echo -e "${YELLOW}Checking CPU Nemotron...${NC}"
if systemctl --user is-active nemotron-cpu >/dev/null 2>&1; then
  echo -e "${GREEN}  CPU Nemotron already active.${NC}"
else
  echo -e "${YELLOW}  Starting CPU Nemotron (will take 2-5 min to load model)...${NC}"
  systemctl --user start nemotron-cpu
fi

echo ""
echo -e "${GREEN}=== Stack Status ===${NC}"
docker ps --format "  {{.Names}}: {{.Status}}" | grep -E "phoenix|litellm|netdata" || true
systemctl --user is-active nemotron-cpu >/dev/null 2>&1 && echo -e "  nemotron-cpu: active" || echo -e "  nemotron-cpu: inactive"
echo -e "${GREEN}=== Done. GPU Nemotron (vLLM): run agent-mode.sh or forensic-mode.sh ===${NC}"

# 5. DeerFlow (research agent, port 2026)
echo -e "${YELLOW}Checking DeerFlow...${NC}"
if docker ps --format '{{.Names}}' | grep -q "deer-flow-nginx"; then
  echo -e "${GREEN}  DeerFlow already running (:2026).${NC}"
else
  echo -e "${YELLOW}  Starting DeerFlow...${NC}"
  cd /data/ai/01-workspace/deerflow && make docker-start 2>&1 | tail -3
fi
