#!/bin/bash
# HL Phase-1 dashboard sync + bot watchdog.
# Runs every 5 min via cron: keeps the DRY_RUN bot alive and pushes data.json to GitHub Pages.
set -u
DASH=/home/hermes/dashboard
TB=/home/hermes/trading-bots
LOG=$TB/logs/bot4_dryrun.log
mkdir -p "$(dirname "$LOG")"

# 1) Watchdog — restart the bot if it is not running (e.g. after a reboot)
if ! pgrep -f "scripts/dashboard_runner.py" >/dev/null 2>&1; then
  cd "$TB" || exit 1
  setsid python3 scripts/dashboard_runner.py --loop --interval 60 >>"$LOG" 2>&1 </dev/null &
  echo "$(date -Iseconds) watchdog: started bot"
fi

# 2) Push the latest dashboard data to GitHub Pages
cd "$DASH" || exit 1
git add -A
if ! git diff --cached --quiet; then
  git commit -q -m "data: auto-update $(date -Iseconds)"
  git push -q
  echo "$(date -Iseconds) synced"
fi
