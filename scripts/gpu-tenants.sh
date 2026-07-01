#!/bin/bash
# gpu-tenants.sh — SINGLE SOURCE OF TRUTH for this box's GPU-capable mode tenants.
#
# Sourced by every *-mode.sh switcher, audio-stop.sh, and mode-picker's StopAll so
# there is ONE complete stop-list instead of five drifting greps. Add any new GPU
# container (one with `runtime: nvidia` in its compose) to GPU_TENANTS below and
# every mode picks it up automatically — this is what kills the OOM-from-stale-load
# bug class (EXECUTION-PLAN B2).
#
# GPU ETIQUETTE (CLAUDE.md): the functions here ONLY ever act on names listed in
# GPU_TENANTS — the box's OWN restartable mode containers. A foreign session's
# resident stack (or any non-mode container) is never touched. Always run
# `nvidia-smi` before GPU work; never evict another session's process.
#
# Canonical list = every container with `runtime: nvidia` in the compose files at
#   /data/ai/06-configs/{vllm-nemotron,vllm-nemotron-agent,vllm-coding,creative-stack,audio}
# Re-derive with:
#   grep -rl 'runtime: *nvidia' /data/ai/06-configs/*/docker-compose.yml \
#     | xargs grep -h container_name
GPU_TENANTS=(
  vllm-nemotron          # forensic vLLM      (:8000, ~28-30GB)
  vllm-nemotron-agent    # agent vLLM         (:8000, ~22GB)
  vllm-coding            # coding vLLM AI-1   (:8000)            [was missing → port :8000 clash]
  creative-comfyui       # ComfyUI            (FLUX / Wan / Hunyuan)
  creative-music         # YuE 7B music       (~16GB)
  creative-tts           # Fish Speech TTS    (lazy VRAM)
  creative-audio-worker  # RQ worker / WhisperX (GPU when a job runs)
  creative-musetalk      # lipsync draft      (lazy VRAM)        [was missing]
  creative-hallo2        # lipsync cinematic  (lazy VRAM)        [was missing]
  creative-latentsync    # lipsync production (lazy VRAM)        [was missing]
)

# confirm_or_assume "<prompt>" — interactive y/N confirm with a non-interactive
#   override for the Mushishi Bridge daemon (which has no TTY).
#
#   Returns 0 (proceed) / non-zero (abort). The caller wires it as:
#     confirm_or_assume "Stop them now?" || { echo "Aborted."; exit 1; }
#
#   SCOPE — read before changing: this helper ONLY decides whether to skip the
#   keyboard prompt. It NEVER changes WHICH tenants are stopped — that is fixed by
#   the surrounding stop_gpu_tenants_except call, untouched. The env override is a
#   convenience for a headless caller that has ALREADY done its own safety check:
#   the daemon MUST run its own busy-guard (gpu_busy_report) before invoking a
#   *-mode.sh, exactly as mode-picker.sh does for the interactive path. The flag
#   does not bypass that guard; it only answers the "press y" question for it.
#
#   MUSHISHI_ASSUME_YES ∈ {1,true,yes,y} (case-insensitive) ⇒ auto-confirm, and
#   announce it on STDERR (never silent — the log must show it was non-interactive).
#   Unset/anything else ⇒ prompt on the TTY. Empty input or EOF (no TTY, no flag)
#   counts as No ⇒ non-zero. This fails CLOSED: without an explicit yes (typed or
#   flagged) the mode switch aborts.
confirm_or_assume() {
  local prompt="$1" ans
  case "${MUSHISHI_ASSUME_YES,,}" in
    1|true|yes|y)
      echo "[MUSHISHI_ASSUME_YES] auto-confirming: ${prompt}" >&2
      return 0
      ;;
  esac
  read -rp "${prompt} [y/N] " ans || return 1
  [[ "$ans" =~ ^[Yy] ]]
}

# stop_gpu_tenants_except [keep ...]
#   Stop every RUNNING GPU tenant whose name is NOT in the keep-list.
#   Only ever touches names in GPU_TENANTS, so foreign processes are safe.
stop_gpu_tenants_except() {
  local keep=" $* "
  local running c
  local stop=()
  running=$(docker ps --format '{{.Names}}' 2>/dev/null || true)
  for c in "${GPU_TENANTS[@]}"; do
    [[ "$keep" == *" $c "* ]] && continue
    if grep -Fxq "$c" <<<"$running"; then stop+=("$c"); fi
  done
  if [ ${#stop[@]} -gt 0 ]; then
    echo "   Stopping GPU tenants: ${stop[*]}"
    docker stop "${stop[@]}" >/dev/null 2>&1 || true
  fi
}

# stop_all_gpu_tenants — free the whole card (used by StopAll).
stop_all_gpu_tenants() { stop_gpu_tenants_except; }

# running_gpu_tenants_except [keep ...]
#   Echo (one per line) the running GPU tenants not in the keep-list.
#   Empty output ⇒ nothing to stop (use to gate confirmation prompts).
running_gpu_tenants_except() {
  local keep=" $* "
  local running c
  running=$(docker ps --format '{{.Names}}' 2>/dev/null || true)
  for c in "${GPU_TENANTS[@]}"; do
    [[ "$keep" == *" $c "* ]] && continue
    if grep -Fxq "$c" <<<"$running"; then echo "$c"; fi
  done
}

# ── Activity probe (idle-vs-working) ─────────────────────────────────────────
# A model that is merely RESIDENT (loaded, holding VRAM, doing nothing) is safe
# to purge — switching modes just frees the card. A model that is WORKING
# (serving requests / running a render / a queued job) must NOT be killed
# silently. These functions tell the two apart so the picker can switch past an
# idle resident without nagging, while still guarding real work. "Loaded" is not
# "busy" — that distinction is the whole point.
#
# Sources, most authoritative first:
#   1. vLLM   :8000 /metrics → vllm:num_requests_running + _waiting   (exact)
#   2. ComfyUI :8188 /queue  → running + pending                       (exact)
#   3. Audio RQ (creative-redis) started/queued registries             (exact)
#   4. GPU SM-util sample — backstop for anything 1-3 don't cover
#      (YuE music, lipsync tiers, or a foreign process). Idle vLLM sits at 0%;
#      a render pegs near 100%.

# gpu_sm_peak — peak GPU compute (SM) utilisation %, sampled a few times (~1.4s).
gpu_sm_peak() {
  local i max=0 u
  for i in 1 2 3; do
    u=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1)
    u=${u// /}
    [[ "$u" =~ ^[0-9]+$ ]] && [ "$u" -gt "$max" ] && max=$u
    [ $i -lt 3 ] && sleep 0.7
  done
  echo "$max"
}

# gpu_busy_report — echo one human line per ACTIVE workload; EMPTY output ⇒ idle.
#   Use the (non-)emptiness to gate a "you'll kill running work" confirmation,
#   and the text itself to tell the user what is running.
gpu_busy_report() {
  local out=""

  # 1. vLLM serving on :8000 (the running/waiting gauges are the ground truth —
  #    a model can hold 29GB and still be 0/0 = idle = purgeable).
  local rw r w model
  rw=$(curl -s -m 3 http://localhost:8000/metrics 2>/dev/null | awk '
    /^vllm:num_requests_running/   {r+=$NF}
    /^vllm:num_requests_waiting\{/ {w+=$NF}
    END { printf "%d %d", r+0, w+0 }')
  r=${rw%% *}; w=${rw##* }
  if [ "${r:-0}" -gt 0 ] || [ "${w:-0}" -gt 0 ]; then
    model=$(curl -s -m 3 http://localhost:8000/v1/models 2>/dev/null \
      | python3 -c "import sys,json;d=json.load(sys.stdin).get('data',[]);print(d[0]['id'] if d else '')" 2>/dev/null)
    out+="vLLM (${model:-:8000}): ${r} request(s) running, ${w} waiting\n"
  fi

  # 2. ComfyUI queue (only if the container is up)
  if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "comfyui"; then
    local q
    q=$(curl -s -m 5 http://localhost:8188/queue 2>/dev/null | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    r, p = len(d.get('queue_running', [])), len(d.get('queue_pending', []))
    if r + p: print(f'ComfyUI: {r} job(s) RUNNING, {p} queued')
except Exception: pass" 2>/dev/null)
    [ -n "$q" ] && out+="$q\n"
  fi

  # 3. Audio stack jobs (RQ queues + in-progress registries)
  if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "creative-redis"; then
    local a run que
    a=$(docker exec creative-redis redis-cli --raw eval "
local total_q, total_run = 0, 0
for _, q in ipairs({'stt','voice','lipsync','music','dub'}) do
  total_q = total_q + redis.call('LLEN', 'rq:queue:' .. q)
  total_run = total_run + redis.call('ZCARD', 'rq:started_job_registry:' .. q)
end
return total_run .. ' ' .. total_q" 0 2>/dev/null)
    run=$(echo "$a" | awk '{print $1}'); que=$(echo "$a" | awk '{print $2}')
    if [ "${run:-0}" -gt 0 ] || [ "${que:-0}" -gt 0 ]; then
      out+="Audio stack: ${run:-0} job(s) RUNNING, ${que:-0} queued\n"
    fi
  fi

  # 4. SM-util backstop — only if 1-3 saw nothing, so we don't pay the ~1.4s
  #    sample when we already know it's busy. Catches GPU work the exact probes
  #    miss (YuE, lipsync, a foreign render) before we call the card "idle".
  if [ -z "$out" ]; then
    local peak; peak=$(gpu_sm_peak)
    if [ "${peak:-0}" -gt 15 ]; then
      out+="GPU compute active: ${peak}% SM util (unrecognised workload — not a vLLM/ComfyUI/audio job)\n"
    fi
  fi

  printf "%b" "$out"
}

# gpu_resident_line — compact one-liner: which of OUR tenants are loaded + the
#   vLLM served-model name (so the picker header can say WHAT is on the card).
gpu_resident_line() {
  local running c model who=""
  local -a tenants=()
  running=$(docker ps --format '{{.Names}}' 2>/dev/null || true)
  for c in "${GPU_TENANTS[@]}"; do
    if grep -Fxq "$c" <<<"$running"; then tenants+=("$c"); fi
  done
  model=$(curl -s -m 2 http://localhost:8000/v1/models 2>/dev/null \
    | python3 -c "import sys,json;d=json.load(sys.stdin).get('data',[]);print(d[0]['id'] if d else '')" 2>/dev/null)
  [ ${#tenants[@]} -gt 0 ] && who="${tenants[*]}"
  [ -n "$model" ] && who="${who:+$who · }${model}"
  [ -z "$who" ] && who="nothing loaded"
  printf '%s' "$who"
}
