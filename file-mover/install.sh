#!/usr/bin/env bash
# ============================================================
#  install.sh — link the script and import the "File Mover"
#  shortcut. The folder automation that triggers it has to be
#  created by hand once; this prints the steps.
#
#  Usage: ./install.sh            # install / reinstall
#         ./install.sh --status   # show current state only
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="$HOME/.config/file-mover"
SHORTCUT_NAME="File Mover"
OLD_PLIST="$HOME/Library/LaunchAgents/com.rnsts.filemover.plist"

# grep without -q: an early exit would SIGPIPE `shortcuts` and fail under pipefail.
shortcut_installed() { shortcuts list | grep -Fx "$SHORTCUT_NAME" >/dev/null; }

if [[ "${1:-}" == "--status" ]]; then
  echo "── shortcut ──"
  shortcut_installed && echo "\"$SHORTCUT_NAME\" installed" || echo "\"$SHORTCUT_NAME\" not installed"
  echo
  echo "── log (last 20) ──"
  tail -20 "$STATE_DIR/file-mover.log" 2>/dev/null || echo "no log at $STATE_DIR/file-mover.log"
  exit 0
fi

# ── Retire the old launchd watcher ───────────────────────────
# It needed Full Disk Access for /bin/bash; the Shortcuts automation doesn't.
if [[ -f "$OLD_PLIST" ]]; then
  launchctl bootout "gui/$(id -u)" "$OLD_PLIST" 2>/dev/null || true
  rm "$OLD_PLIST"
  echo "  removed old launchd agent — remove /bin/bash from Full Disk Access if it's still there"
fi

# ── Link the script where the shortcut calls it ──────────────
mkdir -p "$STATE_DIR"
chmod +x "$SCRIPT_DIR/file-mover.sh" "$SCRIPT_DIR/process_statement.py"
ln -sfn "$SCRIPT_DIR/file-mover.sh" "$STATE_DIR/file-mover.sh"
echo "  linked $STATE_DIR/file-mover.sh"

# ── Import the shortcut ──────────────────────────────────────
if shortcut_installed; then
  echo "  shortcut \"$SHORTCUT_NAME\" already installed"
else
  tmp="$(mktemp -d)"
  # `shortcuts sign` only accepts a binary plist with a .shortcut extension;
  # the output file name becomes the shortcut's name.
  plutil -convert binary1 -o "$tmp/unsigned.shortcut" "$SCRIPT_DIR/file-mover.shortcut.xml"
  shortcuts sign --input "$tmp/unsigned.shortcut" --output "$tmp/$SHORTCUT_NAME.shortcut"
  open "$tmp/$SHORTCUT_NAME.shortcut"
  cat <<EOF
  Opened "$SHORTCUT_NAME" in Shortcuts. Finish there (can't be scripted):
    1. Click Add Shortcut
    2. Settings → Advanced → turn on Allow Running Scripts
    3. Automations → + → Folder → Downloads, tick only Added
       → Run Immediately → Next → pick "$SHORTCUT_NAME"
    4. If asked whether Shortcuts may access Downloads, click Allow
EOF
fi
echo "  check it with: $SCRIPT_DIR/install.sh --status"
