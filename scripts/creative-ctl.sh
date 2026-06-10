#!/bin/bash
# Creative stack controller — called locally or by Hermes agent via SSH
# Usage: ./creative-ctl.sh [start|stop|status|generate|monitor|backup|funnel-on|funnel-off|video-mode|resume-llm]

COMPOSE_FILE="/data/ai/06-configs/creative-stack/docker-compose.yml"
VLLM_COMPOSE="/data/ai/06-configs/vllm/docker-compose.yml"
OUTPUT_DIR="/data/ai/08-portfolio/outputs"
WORKFLOW_DIR="/data/ai/01-workspace/comfyui/user/default/workflows"
GIT_BACKUP_REMOTE="git@github.com:YOUR_USERNAME/comfyui-workflows-private.git"

case "$1" in

  start)
    echo "[creative-ctl] Starting vLLM..."
    docker compose -f $VLLM_COMPOSE up -d
    echo "[creative-ctl] Starting ComfyUI..."
    docker compose -f $COMPOSE_FILE up -d
    echo "[creative-ctl] Stack ready."
    LOCAL_IP=$(tailscale ip -4 2>/dev/null || hostname -I | awk '{print $1}')
    echo "  ComfyUI API: http://${LOCAL_IP}:8188"
    echo "  vLLM API:    http://${LOCAL_IP}:8000"
    ;;

  stop)
    echo "[creative-ctl] Backing up workflows before shutdown..."
    /data/ai/01-workspace/scripts/creative-ctl.sh backup
    echo "[creative-ctl] Stopping creative stack..."
    docker compose -f $COMPOSE_FILE down
    docker compose -f $VLLM_COMPOSE down
    echo "[creative-ctl] Stack stopped. GPU fully free."
    nvidia-smi --query-gpu=memory.free --format=csv,noheader
    ;;

  status)
    echo "=== GPU (per-process) ==="
    nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv,noheader 2>/dev/null       || nvidia-smi --query-gpu=name,memory.used,memory.free,temperature.gpu --format=csv,noheader
    echo ""
    echo "=== GPU Summary ==="
    nvidia-smi --query-gpu=name,memory.used,memory.free,temperature.gpu --format=csv,noheader
    echo ""
    echo "=== Containers ==="
    docker ps --filter "name=creative-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    ;;

  generate)
    # Submit a ComfyUI workflow via API
    # Hermes passes workflow object JSON as $2
    # ComfyUI expects {"prompt": <workflow_object>}
    WORKFLOW_JSON="$2"
    if [ -z "$WORKFLOW_JSON" ]; then
      echo "Usage: $0 generate '<workflow_json>'"
      exit 1
    fi
    RESPONSE=$(curl -s -X POST http://localhost:8188/prompt \
      -H "Content-Type: application/json" \
      -d "{"prompt": ${WORKFLOW_JSON}}")
    PROMPT_ID=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('prompt_id','error'))" 2>/dev/null)
    echo "[creative-ctl] Job queued: $PROMPT_ID"
    echo "$PROMPT_ID"
    ;;

  monitor)
    # Live per-process VRAM monitor — stays running until Ctrl+C
    # Uses nvitop if available, falls back to watch+nvidia-smi
    echo "[creative-ctl] Starting VRAM monitor (Ctrl+C to exit)..."
    if command -v nvitop &>/dev/null; then
      nvitop
    elif docker images | grep -q nvitop; then
      docker run --rm --gpus all --pid=host wernight/nvitop
    else
      echo "[creative-ctl] nvitop not found — using nvidia-smi watch (install nvitop for per-process detail)"
      watch -n 2 nvidia-smi
    fi
    ;;

  backup)
    # Push ComfyUI workflows to private Git repo
    if [ ! -d "$WORKFLOW_DIR/.git" ]; then
      echo "[creative-ctl] Initialising workflow Git repo..."
      git -C "$WORKFLOW_DIR" init
      git -C "$WORKFLOW_DIR" remote add origin "$GIT_BACKUP_REMOTE" 2>/dev/null || true
    fi
    cd "$WORKFLOW_DIR"
    git add -A
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M")
    CHANGED=$(git diff --cached --name-only | wc -l)
    if [ "$CHANGED" -gt 0 ]; then
      git commit -m "auto-backup: $CHANGED workflow(s) — $TIMESTAMP"
      git push origin main 2>/dev/null         && echo "[creative-ctl] Workflows backed up to Git ($CHANGED files)."         || echo "[creative-ctl] Git push failed — check remote config. Local commit saved."
    else
      echo "[creative-ctl] No workflow changes since last backup."
    fi
    ;;

  funnel-on)
    # Expose ComfyUI port publicly via Tailscale Funnel (portfolio sharing)
    # Accessible at: https://your-machine-name.tail12345.ts.net
    echo "[creative-ctl] Enabling Tailscale Funnel on port 8188..."
    sudo tailscale funnel --bg 8188
    echo "[creative-ctl] ComfyUI now publicly accessible at:"
    tailscale funnel status 2>/dev/null | grep "https://" || echo "  Run: tailscale funnel status to get your URL"
    echo ""
    echo "[creative-ctl] WARNING: Anyone with the URL can access your ComfyUI."
    echo "              Disable when done: ./creative-ctl.sh funnel-off"
    ;;

  funnel-off)
    echo "[creative-ctl] Disabling Tailscale Funnel..."
    sudo tailscale funnel --bg off
    echo "[creative-ctl] ComfyUI is private again (Tailscale-only)."
    ;;

  video-mode)
    echo "[creative-ctl] Stopping vLLM — full VRAM for video generation..."
    docker stop creative-vllm
    FREE=$(nvidia-smi --query-gpu=memory.free --format=csv,noheader)
    echo "[creative-ctl] Done. ${FREE} VRAM now free."
    ;;

  resume-llm)
    echo "[creative-ctl] Restarting vLLM..."
    docker start creative-vllm
    echo "[creative-ctl] vLLM starting — ready in ~60s."
    ;;

  *)
    echo "Usage: $0 {start|stop|status|generate|monitor|backup|funnel-on|funnel-off|video-mode|resume-llm}"
    echo ""
    echo "  start        — Start vLLM + ComfyUI containers"
    echo "  stop         — Backup workflows, then stop all containers"
    echo "  status       — GPU usage, container health"
    echo "  generate     — Submit workflow JSON to ComfyUI API"
    echo "  monitor      — Live per-process VRAM monitor"
    echo "  backup       — Push ComfyUI workflows to Git"
    echo "  funnel-on    — Expose ComfyUI publicly via Tailscale Funnel"
    echo "  funnel-off   — Make ComfyUI private again"
    echo "  video-mode   — Stop vLLM, free all VRAM for video generation"
    echo "  resume-llm   — Restart vLLM after video generation"
    exit 1
    ;;

esac

