#!/usr/bin/env bash
# ============================================================
#  install.sh — render the launchd plist and (re)load the agent
#
#  Usage: ./install.sh            # install / reinstall
#         ./install.sh --status   # show current state only
# ============================================================

set -euo pipefail

LABEL="com.rnsts.filemover"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/file-mover.sh"
PLIST_SRC="$SCRIPT_DIR/com.rnsts.filemover.plist.template"
PLIST_DEST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG_DIR="$HOME/.config/file-mover"
DOMAIN="gui/$(id -u)"

if [[ "${1:-}" == "--status" ]]; then
  echo "── launchctl print ──"
  launchctl print "$DOMAIN/$LABEL" 2>&1 | sed -n '1,25p' || echo "not loaded"
  echo
  echo "── watcher log (last 20) ──"
  tail -20 "$LOG_DIR/file-mover.log" 2>/dev/null || echo "no log at $LOG_DIR/file-mover.log"
  echo
  echo "── launchd stderr (last 20) ──"
  tail -20 "$LOG_DIR/launchd-error.log" 2>/dev/null || echo "no launchd-error.log"
  exit 0
fi

# ── Preflight ────────────────────────────────────────────────
command -v fswatch >/dev/null || { echo "fswatch not found — brew install fswatch"; exit 1; }
[[ -f "$SCRIPT"    ]] || { echo "missing $SCRIPT"; exit 1; }
[[ -f "$PLIST_SRC" ]] || { echo "missing $PLIST_SRC"; exit 1; }

mkdir -p "$LOG_DIR" "$HOME/Library/LaunchAgents" "$HOME/Documents/finance/statements"
chmod +x "$SCRIPT"

# ── Render the template ──────────────────────────────────────
sed -e "s|__SCRIPT__|$SCRIPT|g" \
    -e "s|__LOG_DIR__|$LOG_DIR|g" \
    "$PLIST_SRC" > "$PLIST_DEST"
plutil -lint "$PLIST_DEST"

# ── Reload the agent ─────────────────────────────────────────
launchctl bootout   "$DOMAIN/$LABEL" 2>/dev/null || true
launchctl bootstrap "$DOMAIN" "$PLIST_DEST"
launchctl kickstart -k "$DOMAIN/$LABEL"

echo "Loaded $LABEL — verifying..."
sleep 2
launchctl print "$DOMAIN/$LABEL" | grep -E 'state|pid|program|path' || true

# ── Smoke test ───────────────────────────────────────────────
PROBE="$HOME/Downloads/BE00000000000000_Statements_until_01-01-2000.csv"
printf 'Accountnumber;Heading;Name;Currency;Statement number;Date\nBE00;;PROBE USER;EUR;1;01/01/2000\n' > "$PROBE"
echo "Dropped probe file, waiting 8s..."
sleep 8

if grep -q "Statements_until_01-01-2000" "$LOG_DIR/file-mover.log" 2>/dev/null; then
  echo "OK — watcher saw the probe. See $HOME/Documents/finance/statements/"
else
  echo "FAIL — watcher did not react to the probe."
  echo "Most likely cause: launchd agents have no TCC access to ~/Downloads."
  echo "Fix: System Settings > Privacy & Security > Full Disk Access > add /bin/bash"
  echo "     (press Cmd+Shift+G in the file picker to type the path), then rerun this script."
  rm -f "$PROBE"
fi
