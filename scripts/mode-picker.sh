#!/bin/bash
# mode-picker.sh — Graphical GPU-mode chooser, shown at desktop login (v1.8)
# Autostart entry: ~/.config/autostart/mushishi-mode-picker.desktop
# CPU Nemotron (:8001, systemd --user) stays up in every mode — sovereignty floor.
# Future: replace per-mode scripts with unified mode.sh (EXECUTION-PLAN task B2),
# then this picker only needs its case-branches updated.

SCRIPTS="/data/ai/01-workspace/scripts"

# Current GPU state for the dialog subtitle
VRAM=$(nvidia-smi --query-gpu=memory.used,memory.free --format=csv,noheader 2>/dev/null || echo "GPU query failed")

CHOICE=$(zenity --list --radiolist \
  --title="Mushishi — what are you working on?" \
  --text="One GPU mode at a time (RTX 5090 32GB).\nCPU Nemotron floor stays on regardless.\n\nVRAM now: ${VRAM}" \
  --column="" --column="Mode" --column="What runs" \
  TRUE  "Nothing"   "Leave GPU empty — decide later" \
  FALSE "AI"        "vLLM Nemotron (~28-30GB) — agent + forensic work (NOTE: separate light agent config not built yet, see plan B2)" \
  FALSE "Creative"  "ComfyUI (~14-24GB) — FLUX / Wan / Hunyuan generation" \
  FALSE "Audio"     "Audio stack full tier (~16GB) — TTS / lipsync / avatar" \
  FALSE "Music"     "YuE 7B (~16GB) — stops vLLM AND ComfyUI" \
  --width=680 --height=360 2>/dev/null)

[ -z "$CHOICE" ] || [ "$CHOICE" = "Nothing" ] && exit 0

case "$CHOICE" in
  AI)       CMD="$SCRIPTS/forensic-mode.sh" ;;
  Creative) CMD="$SCRIPTS/creative-mode.sh" ;;
  Audio)    CMD="$SCRIPTS/audio-mode.sh" ;;
  Music)    CMD="$SCRIPTS/music-mode.sh" ;;
  *) exit 0 ;;
esac

# Run in a visible terminal — mode scripts print progress and music-mode.sh
# has an interactive confirm prompt.
gnome-terminal --title="Mushishi mode switch: $CHOICE" -- bash -c \
  "$CMD; echo; read -p '--- Done. Press Enter to close ---'"
