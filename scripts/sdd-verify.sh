#!/bin/bash
# sdd-verify.sh — Mushishi SDD health check runner
# Usage: ./sdd-verify.sh [--spec <spec-file>]
set -e
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'

PASS=0; FAIL=0

check() {
    local id="$1"; local desc="$2"; local cmd="$3"
    if eval "$cmd" > /dev/null 2>&1; then
        echo -e "  ${GREEN}PASS${NC} [$id] $desc"
        PASS=$((PASS+1))
    else
        echo -e "  ${RED}FAIL${NC} [$id] $desc"
        FAIL=$((FAIL+1))
    fi
}

echo -e "${YELLOW}=== Mushishi SDD Verify ===${NC}"
echo ""

echo "--- Core stack ---"
check "redis"       "Redis PONG"                    "docker exec creative-redis redis-cli ping | grep -q PONG"
check "litellm"     "LiteLLM proxy reachable"       "curl -s http://localhost:4000/health | grep -qE 'error|models|healthy'"
check "phoenix"     "Arize Phoenix reachable"       "curl -sf -o /dev/null http://localhost:6006"
check "netdata"     "Netdata reachable"             "curl -sf -o /dev/null http://localhost:19999"
check "nemotron-cpu" "CPU Nemotron service"         "systemctl is-active --user nemotron-cpu"

echo ""
echo "--- Audio stack (Phase A) ---"
check "audio-gw"    "Audio gateway health"          "curl -sf http://localhost:9000/audio/health"
check "redis-ping"  "Redis PONG"                    "docker exec creative-redis redis-cli ping | grep -q PONG"
check "rq-dash"     "rq-dashboard reachable"        "curl -sf -o /dev/null http://localhost:9010/"

echo ""
echo "--- Audio models ---"
check "whisper"     "Whisper V3-Turbo weights"      "test -f /data/ai/02-models/audio/whisper/whisper-large-v3-turbo/model.safetensors"
check "fish-speech" "Fish Speech 1.5 weights"       "test -d /data/ai/02-models/audio/fish-speech/fish-speech-1.5 && [ \$(ls /data/ai/02-models/audio/fish-speech/fish-speech-1.5 | wc -l) -gt 0 ]"
check "musetalk"    "MuseTalk weights"              "test -d /data/ai/02-models/audio/museTalk && [ \$(ls /data/ai/02-models/audio/museTalk | wc -l) -gt 0 ]"
check "ace-step"    "ACE-Step weights"              "test -d /data/ai/02-models/audio/ace-step && [ \$(ls /data/ai/02-models/audio/ace-step | wc -l) -gt 0 ]"
check "stable-audio" "Stable Audio weights"         "test -d /data/ai/02-models/audio/stable-audio && [ \$(ls /data/ai/02-models/audio/stable-audio | wc -l) -gt 0 ]"

echo ""
echo "--- Disk + VRAM ---"
check "disk-ok"     "/data/ai < 85% full"           "[ \$(df /data/ai | awk 'NR==2{print \$5}' | tr -d '%') -lt 85 ]"
check "vram-ok"     "VRAM > 5GB free"               "[ \$(nvidia-smi --query-gpu=memory.free --format=csv,noheader,nounits) -gt 5000 ]"

echo ""
TOTAL=$((PASS+FAIL))
if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}=== ALL $TOTAL CHECKS PASSED ===${NC}"
else
    echo -e "${RED}=== $FAIL/$TOTAL FAILED ===${NC}"
    exit 1
fi
