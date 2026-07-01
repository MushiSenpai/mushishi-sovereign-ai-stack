#!/bin/bash
# agent-mode.sh — Nemotron LIGHT (:8000, ~22GB) + light audio stack, coexisting
# EXECUTION-PLAN task B2. Use case: pipelines needing vision + TTS in one run
# (comic-narrator single-pass) and general agent work with TTS on tap.
# Heavy audio (lipsync/music tiers) still requires audio-mode.sh / music-mode.sh.
set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

# Shared, complete GPU-tenant stop-list (EXECUTION-PLAN B2)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/gpu-tenants.sh"

AGENT_COMPOSE="/data/ai/06-configs/vllm-nemotron-agent"
AUDIO_COMPOSE="/data/ai/06-configs/audio"
VLLM_URL="http://localhost:8000/v1/models"

echo -e "${YELLOW}🤖 AGENT MODE — Nemotron light + Fish Speech coexisting...${NC}"

sudo nvidia-smi -pl 450 > /dev/null 2>&1 || true

# Free the card for the agent vLLM, keeping only the light audio coexistents
# (worker + Fish Speech). This stops forensic vLLM (same :8000), vllm-coding
# (same :8000), ComfyUI, YuE music, and ALL lipsync tiers — the complete list
# lives in gpu-tenants.sh so it can never drift again.
stop_gpu_tenants_except vllm-nemotron-agent creative-audio-worker creative-tts
sleep 3

# Start Nemotron light
if docker ps --format '{{.Names}}' | grep -qx "vllm-nemotron-agent"; then
  echo -e "${GREEN}   vllm-nemotron-agent already running.${NC}"
else
  echo "   Starting vLLM (agent-light config)..."
  cd "$AGENT_COMPOSE"
  docker compose up -d
fi

# Start light audio services (worker is mandatory — gateway only enqueues)
echo "   Starting Redis, gateway, worker, Fish Speech..."
cd "$AUDIO_COMPOSE"
docker compose up -d redis rq-dashboard audio-gateway audio-worker fish-speech

echo "   Waiting for vLLM model load (2-10 min)..."
MAX_WAIT=900; WAITED=0
while ! curl -s "$VLLM_URL" > /dev/null 2>&1; do
  sleep 10; WAITED=$((WAITED + 10)); echo -n "."
  if [ $WAITED -ge $MAX_WAIT ]; then
    echo -e "\n${RED}❌ vLLM timeout. docker logs vllm-nemotron-agent${NC}" && exit 1
  fi
done
echo ""

echo "   Waiting for audio gateway..."
MAX_WAIT=60; WAITED=0
while ! curl -s http://localhost:9000/audio/health > /dev/null 2>&1; do
  sleep 5; WAITED=$((WAITED + 5)); echo -n "."
  if [ $WAITED -ge $MAX_WAIT ]; then
    echo -e "\n${RED}❌ Gateway timeout. docker logs creative-audio-gateway${NC}" && exit 1
  fi
done

echo ""
echo -e "${GREEN}✅ AGENT MODE READY — Nemotron :8000 (32K ctx) + audio gateway :9000${NC}"
nvidia-smi --query-gpu=memory.used,memory.free,power.draw --format=csv,noheader
echo ""
echo "Single-pass comic-narrator now works: comic-narrator page.jpg --layout manga -o out.mp4"
