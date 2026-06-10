#!/bin/bash
# healthcheck.sh — Silent-failure watchdog (v1.8)
# Born from the 2026-06-10 incident: restic backup failed silently for 2.5 weeks.
# Checks the things that fail QUIETLY and pushes to your phone via ntfy ONLY when
# something is wrong (plus a Monday "I'm alive" heartbeat so you know the watchdog
# itself works). Runs daily via systemd user timer: mushishi-healthcheck.timer
#
# Phone setup (one-time): install the ntfy app (Android/iOS) and subscribe to
# the topic below. Topic is unguessable — treat it like a password.
# Future (Phase 6): point NTFY_URL at self-hosted ntfy on the VPS.

NTFY_URL="https://ntfy.sh"
NTFY_TOPIC="your-unguessable-topic-here"
RESTIC="/home/mushi/.local/bin/restic"
REPO="/data/ai/09-restic-repo"
PASS_FILE="/home/mushi/.restic-password"

PROBLEMS=()

# ── 1. Backup freshness: newest restic snapshot must be < 8 days old ─────────
if [ -f "$PASS_FILE" ]; then
  LAST_EPOCH=$("$RESTIC" -r "$REPO" --password-file "$PASS_FILE" snapshots --latest 1 --json 2>/dev/null \
    | python3 -c "import sys,json,datetime; s=json.load(sys.stdin); t=s[-1]['time'][:19]; print(int(datetime.datetime.fromisoformat(t).timestamp()))" 2>/dev/null)
  if [ -z "$LAST_EPOCH" ]; then
    PROBLEMS+=("Backup: cannot read restic snapshots at all")
  else
    AGE_DAYS=$(( ($(date +%s) - LAST_EPOCH) / 86400 ))
    [ "$AGE_DAYS" -ge 8 ] && PROBLEMS+=("Backup: last restic snapshot is ${AGE_DAYS} days old (cron broken again?)")
  fi
else
  PROBLEMS+=("Backup: restic password file missing")
fi

# ── 2. Disk usage: warn at 90% on the partitions that matter ────────────────
while read -r use mount; do
  PCT=${use%\%}
  [ "$PCT" -ge 90 ] && PROBLEMS+=("Disk: ${mount} at ${use}")
done < <(df --output=pcent,target / /var /data 2>/dev/null | tail -n +2)

# ── 3. Always-on services (mode-dependent services are NOT checked) ──────────
systemctl --user is-active nemotron-cpu >/dev/null 2>&1 \
  || PROBLEMS+=("Service: nemotron-cpu (CPU sovereignty floor) is DOWN")
for c in litellm-proxy netdata; do
  docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^${c}$" \
    || PROBLEMS+=("Container: ${c} not running")
done

# ── 4. Backup log: catch error lines from the last cron run ─────────────────
if [ -f /data/ai/04-logs/backup.log ]; then
  tail -20 /data/ai/04-logs/backup.log | grep -qiE "command not found|Fatal|error" \
    && PROBLEMS+=("Backup log: errors in last entries of backup.log")
fi

# ── Report ───────────────────────────────────────────────────────────────────
if [ ${#PROBLEMS[@]} -gt 0 ]; then
  printf -v BODY '%s\n' "${PROBLEMS[@]}"
  curl -s -m 10 -H "Title: mushishi: ${#PROBLEMS[@]} problem(s)" -H "Priority: high" -H "Tags: warning" \
    -d "$BODY" "$NTFY_URL/$NTFY_TOPIC" >/dev/null
  echo "$(date '+%F %T') PROBLEMS: ${PROBLEMS[*]}"
elif [ "$(date +%u)" = "1" ]; then
  # Monday heartbeat — proves the watchdog itself is alive
  curl -s -m 10 -H "Title: mushishi healthcheck" -H "Tags: white_check_mark" \
    -d "All checks pass. Last backup ${AGE_DAYS:-?} day(s) ago." "$NTFY_URL/$NTFY_TOPIC" >/dev/null
  echo "$(date '+%F %T') OK (heartbeat sent)"
else
  echo "$(date '+%F %T') OK"
fi
