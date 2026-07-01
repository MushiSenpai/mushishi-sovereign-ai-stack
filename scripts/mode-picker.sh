#!/bin/bash
# mode-picker.sh — Graphical GPU-mode switcher (v3, 2026-06-24)
# Runs at login (autostart) AND on demand from the app grid ("Mushishi Mode").
# Modes: Coding / Forensic / Agent / Creative / Audio / Music / StopAll.
# Smart guards: an activity probe (gpu-tenants.sh) tells a model that is merely
# RESIDENT (loaded, idle → safe to purge) apart from one actually WORKING
# (request in flight, queued render, live GPU compute). It shows what's loaded +
# an IDLE/BUSY verdict, switches past an idle model without nagging, and asks for
# confirmation ONLY when real work would be killed.
# CPU floors survive every mode — sovereignty: Nemotron :8001 + Qwen-coder :8002.

SCRIPTS="/data/ai/01-workspace/scripts"

# Shared GPU-tenant stop-list + activity probe (single source of truth).
source "$SCRIPTS/gpu-tenants.sh"

# ── Probe the card ONCE, before the dialog ───────────────────────────────────
# Answers the two questions the picker exists to answer: WHAT is on the card, and
# is it actually WORKING or merely RESIDENT (loaded, idle, safe to purge). The
# same $BUSY result gates the kill-confirmation below, so we probe only once.
VRAM_LINE=$(nvidia-smi --query-gpu=memory.used,memory.free --format=csv,noheader,nounits 2>/dev/null)
VRAM_USED=$(echo "$VRAM_LINE" | awk -F',' '{gsub(/ /,"",$1); print $1}')
VRAM_FREE=$(echo "$VRAM_LINE" | awk -F',' '{gsub(/ /,"",$2); print $2}')
[ -z "$VRAM_USED" ] && VRAM_USED="?" && VRAM_FREE="?"

RESIDENT="$(gpu_resident_line)"
BUSY="$(gpu_busy_report)"          # non-empty ⇒ real work in progress
if [ -n "$BUSY" ]; then
  STATUS="⚠ BUSY — work in progress; switching kills it"
elif [ "$RESIDENT" = "nothing loaded" ]; then
  STATUS="○ card is free"
else
  STATUS="✓ IDLE — loaded but doing no work, safe to purge"
fi

CHOICE=$(zenity --list --radiolist \
  --title="Mushishi — switch GPU mode" \
  --text="One GPU mode at a time (RTX 5090 32GB).\nCPU floors stay up regardless: Nemotron :8001 · Qwen-coder :8002.\n\nVRAM: ${VRAM_USED} MiB used / ${VRAM_FREE} MiB free\nLoaded: ${RESIDENT}\nStatus: ${STATUS}" \
  --column="" --column="Mode" --column="What runs" \
  TRUE  "Nothing"   "Leave as-is / just checking status" \
  FALSE "Coding"    "Qwen3-Coder 30B-AWQ (:8000, ~29GB) — Claude Code backend; CPU :8002 fallback" \
  FALSE "Forensic"  "Nemotron omni 30B (:8000, 180K ctx) — video / multimodal analysis" \
  FALSE "Agent"     "Nemotron light (:8000, ~22GB) + Fish Speech — agent work with voice" \
  FALSE "Creative"  "ComfyUI (~14-24GB) — FLUX / Wan / Hunyuan generation" \
  FALSE "Audio"     "Audio stack full tier (~16GB) — TTS / lipsync / avatar" \
  FALSE "Music"     "YuE 7B (~16GB) — stops every vLLM AND ComfyUI" \
  FALSE "StopAll"   "Stop every GPU service — free the whole card" \
  --width=780 --height=660 2>/dev/null)

[ -z "$CHOICE" ] || [ "$CHOICE" = "Nothing" ] && exit 0

# ── Confirmation — ONLY when the card is actually working ───────────────────
# A loaded-but-idle model is purged without a prompt (that's the point); we only
# stop to ask when $BUSY found a request in flight, a queued render, or live
# GPU compute. Reuses the single probe above.
if [ -n "$BUSY" ]; then
  zenity --question --width=520 \
    --title="Active work in progress" \
    --text="The GPU is not just loaded — it is WORKING:\n\n$BUSY\nSwitching to <b>$CHOICE</b> will stop this; running job(s) will be lost. Continue?" \
    --ok-label="Switch anyway" --cancel-label="Cancel" 2>/dev/null || exit 0
fi

case "$CHOICE" in
  Coding)   CMD="$SCRIPTS/coding-mode.sh" ;;
  Forensic) CMD="$SCRIPTS/forensic-mode.sh" ;;
  Agent)    CMD="$SCRIPTS/agent-mode.sh" ;;
  Creative) CMD="$SCRIPTS/creative-mode.sh" ;;
  Audio)    CMD="$SCRIPTS/audio-mode.sh" ;;
  Music)    CMD="$SCRIPTS/music-mode.sh" ;;
  StopAll)  CMD="source $SCRIPTS/gpu-tenants.sh; $SCRIPTS/audio-stop.sh; stop_all_gpu_tenants; nvidia-smi --query-gpu=memory.used,memory.free --format=csv,noheader" ;;
  *) exit 0 ;;
esac

gnome-terminal --title="Mushishi mode switch: $CHOICE" -- bash -c \
  "$CMD; echo; read -p '--- Done. Press Enter to close ---'"
