#!/bin/bash
# creative-mode.sh — Switch to ComfyUI creative stack
# Use case: forensic JSON bundle exists on disk, ready to run ComfyUI workflow
# Sequential: stops vllm-nemotron if running, flushes VRAM, brings up ComfyUI
set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

COMFYUI_COMPOSE="/data/ai/06-configs/comfyui"
COMFYUI_URL="http://localhost:8188"
VRAM_TARGET_GB=${1:-24}
VRAM_TARGET_MB=$((VRAM_TARGET_GB * 1024))

echo -e "${YELLOW}🎨 CREATIVE MODE — Switching to ComfyUI (target: ${VRAM_TARGET_GB}GB free)...${NC}"

if docker ps --format '{{.Names}}' | grep -q "vllm-nemotron"; then
  echo -e "${YELLOW}⚠️  vllm-nemotron running (~28-30GB VRAM). Stop to free for ComfyUI?${NC}"
  read -p "   Stop now? (y/N): " confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    docker stop vllm-nemotron || true
    sleep 5
  else
    echo "Aborted." && exit 1
  fi
fi

VRAM_FREE_MB=$(nvidia-smi --query-gpu=memory.free --format=csv,noheader,nounits)
if [ "$VRAM_FREE_MB" -lt "$VRAM_TARGET_MB" ]; then
  echo -e "${RED}❌ Insufficient VRAM: $((VRAM_FREE_MB / 1024))GB free (need ${VRAM_TARGET_GB}GB).${NC}"
  echo "   Check: nvidia-smi · docker ps · fuser /dev/nvidia*"
  exit 1
fi

if docker ps --format '{{.Names}}' | grep -qE "comfyui|creative-stack"; then
  echo -e "${GREEN}✅ ComfyUI already running on :8188.${NC}"
  nvidia-smi --query-gpu=memory.used,memory.free,power.draw,temperature.gpu --format=csv,noheader
  exit 0
fi

echo "   Starting ComfyUI container..."
cd "$COMFYUI_COMPOSE"
docker compose up -d

echo "   Waiting for ComfyUI to be ready (30-90 sec)..."
MAX_WAIT=120; WAITED=0
while ! curl -s "$COMFYUI_URL" > /dev/null 2>&1; do
  sleep 5; WAITED=$((WAITED + 5)); echo -n "."
  if [ $WAITED -ge $MAX_WAIT ]; then
    echo -e "\n${RED}❌ Timeout. docker logs comfyui${NC}" && exit 1
  fi
done

echo ""
echo -e "${GREEN}✅ COMFYUI CREATIVE MODE READY — Port 8188${NC}"
nvidia-smi --query-gpu=memory.used,memory.free,power.draw,temperature.gpu --format=csv,noheader
echo ""
echo "Next: Load _final-bundle.json as conditioning input in ComfyUI workflow"
