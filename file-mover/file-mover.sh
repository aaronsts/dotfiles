#!/usr/bin/env bash
# ============================================================
#  file-mover.sh
#  Files bank statement exports from ~/Downloads: strips
#  unwanted columns, renames them, and saves them under
#  ~/Documents/finance/statements. Runs once per call — a
#  Shortcuts folder automation on ~/Downloads triggers it
#  (see file-mover.shortcut.xml). Every run scans the whole
#  folder, so anything a missed trigger left behind is
#  picked up by the next one.
# ============================================================

# Shortcuts starts us with a minimal PATH, so make sure Homebrew
# (Apple Silicon or Intel) is reachable for python3.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

WATCH_DIR="$HOME/Downloads"
DEST_DIR="$HOME/Documents/finance/statements"
STATE_DIR="$HOME/.config/file-mover"
LOG_FILE="$STATE_DIR/file-mover.log"
LOCK_FILE="$STATE_DIR/file-mover.lock"
# Installed as a symlink in $STATE_DIR — resolve it to find process_statement.py.
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/process_statement.py"

# ── Helpers ──────────────────────────────────────────────────

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

process_csv() {
  local filepath="$1"
  local filename
  filename=$(basename "$filepath")
  python3 "$PYTHON_SCRIPT" "$filepath" "$DEST_DIR" "$filename" 2>&1
}

has_partial_downloads() {
  compgen -G "$WATCH_DIR/*.part" >/dev/null ||
    compgen -G "$WATCH_DIR/*.crdownload" >/dev/null ||
    compgen -G "$WATCH_DIR/*.download" >/dev/null
}

mkdir -p "$STATE_DIR"

# ── One run at a time ─────────────────────────────────────────
# One download can fire the automation more than once; shlock
# also clears a lock left by a run that died.

locked=false
for _ in {1..120}; do
  if shlock -f "$LOCK_FILE" -p $$; then locked=true; break; fi
  sleep 1
done
$locked || { log "Another run held the lock for 2 min — skipping"; exit 0; }
trap 'rm -f "$LOCK_FILE"' EXIT

# ── Let in-progress downloads finish ──────────────────────────
# Browsers write to a temp name and rename it when done, and that
# rename doesn't re-trigger the automation.

for _ in {1..60}; do
  has_partial_downloads || break
  sleep 1
done

# ── Scan ─────────────────────────────────────────────────────

for filepath in "$WATCH_DIR"/*; do
  [[ -f "$filepath" ]] || continue
  filename=$(basename "$filepath")

  [[ "$filename" == *.crdownload ]] && continue
  [[ "$filename" == *.part ]]       && continue

  # ── Rule: contains "Afschriften" or "Statements" ──────────
  if [[ "$filename" == *Afschriften* ]] || [[ "$filename" == *Statements* ]]; then
    log "Matched: $filename"

    # Process (strip columns + rename + move)
    result=$(process_csv "$filepath")
    if echo "$result" | grep -q "^SAVED:"; then
      dest=$(echo "$result" | grep "^SAVED:" | cut -d: -f2-)
      log "Processed & saved to: $dest"
      rm "$filepath"
      log "Removed original: $filepath"
    else
      log "ERROR processing $filename — reason: $result"
      mkdir -p "$DEST_DIR"
      mv "$filepath" "$DEST_DIR/"
    fi
  fi
done
