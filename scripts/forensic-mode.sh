#!/bin/bash
# forensic-mode.sh — Start vLLM Nemotron in forensic config (high VRAM, 180K context)
# Use case: about to run a client video analysis job (T1)
set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

VLLM_COMPOSE="/data/ai/06-configs/vllm-nemotron"
VLLM_URL="http://localhost:8000/v1/models"

echo -e "${YELLOW}🔬 FORENSIC MODE — Starting Nemotron with full multimodal config...${NC}"

sudo nvidia-smi -pl 450 > /dev/null 2>&1 || true

if docker ps --format '{{.Names}}' | grep -qE "comfyui|creative-stack"; then
  echo -e "${YELLOW}⚠️  Creative stack containers running — will conflict with Nemotron VRAM.${NC}"
  read -p "   Stop them now? (y/N): " confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    docker stop $(docker ps --format '{{.Names}}' | grep -E "comfyui|creative-stack") || true
    sleep 5
  else
    echo "Aborted." && exit 1
  fi
fi

if docker ps --format '{{.Names}}' | grep -q "vllm-nemotron"; then
  echo -e "${GREEN}✅ vLLM Nemotron already running on :8000.${NC}"
  exit 0
fi

echo "   Starting vLLM container..."
cd "$VLLM_COMPOSE"
docker compose up -d

echo "   Waiting for model to load (5-10 min on first run, 2-3 min after weights cached)..."
MAX_WAIT=900; WAITED=0
while ! curl -s "$VLLM_URL" > /dev/null 2>&1; do
  sleep 10; WAITED=$((WAITED + 10)); echo -n "."
  if [ $WAITED -ge $MAX_WAIT ]; then
    echo -e "\n${RED}❌ Timeout. docker logs vllm-nemotron${NC}" && exit 1
  fi
done

echo ""
echo -e "${GREEN}✅ NEMOTRON FORENSIC MODE READY — Port 8000${NC}"
nvidia-smi --query-gpu=memory.used,memory.free,power.draw,temperature.gpu --format=csv,noheader
echo ""
echo "Next: ./client-job.sh <video_path> <job_id>"
