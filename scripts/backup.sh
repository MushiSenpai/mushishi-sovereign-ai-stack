#!/bin/bash
# backup.sh — Incremental encrypted backup
# Primary target: /data/ai/09-restic-repo (local tier)
# Phase 6: add second repo on VPS storage box (restic copy or second backup run)
set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

# Absolute path — cron's PATH does not include ~/.local/bin (this broke every
# Sunday backup until 2026-06-10; cron logged "restic: command not found")
RESTIC="/home/mushi/.local/bin/restic"

BACKUP_REPO="/data/ai/09-restic-repo"
PASS_FILE="/home/mushi/.restic-password"

if [ ! -f "$PASS_FILE" ]; then
  echo -e "${YELLOW}First run — initializing restic repo.${NC}"
  read -sp "Enter backup encryption password (save this!): " PASS
  echo
  echo "$PASS" > "$PASS_FILE"; chmod 600 "$PASS_FILE"
  "$RESTIC" -r "$BACKUP_REPO" init --password-file "$PASS_FILE"
fi

echo -e "${YELLOW}Backup starting...${NC}"
# Coverage: everything hand-written or irreplaceable. Model weights and
# git-cloned repos are re-downloadable and stay excluded — EXCEPT cloned
# voice profiles (02-models/audio/voices) which are user data.
"$RESTIC" -r "$BACKUP_REPO" --password-file "$PASS_FILE" backup \
  ~/.hermes/memory ~/.hermes/skills ~/.hermes/config.yaml ~/.hermes/profiles \
  /data/ai/01-workspace/scripts \
  /data/ai/01-workspace/audio/gateway \
  /data/ai/01-workspace/nemotron-forensic \
  /data/ai/01-workspace/comfyui/user \
  /data/ai/02-models/audio/voices \
  /data/ai/06-configs \
  /data/ai/04-logs \
  /data/ai/08-portfolio \
  --exclude /data/ai/07-cache \
  --exclude /data/ai/06-configs/litellm/pgdata \
  --tag "$(date +%Y-%m-%d)"

# Prune: keep 7 daily, 4 weekly, 3 monthly
"$RESTIC" -r "$BACKUP_REPO" --password-file "$PASS_FILE" \
  forget --keep-daily 7 --keep-weekly 4 --keep-monthly 3 --prune

echo -e "${GREEN}Backup complete.${NC}"
"$RESTIC" -r "$BACKUP_REPO" --password-file "$PASS_FILE" snapshots | tail -5
