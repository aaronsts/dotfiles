#!/usr/bin/env bash
# ============================================================
#  file-mover.sh
#  Watches ~/Downloads for bank statement exports, strips
#  unwanted columns, renames them, and files them under
#  ~/Documents/finance/statements. Runs continuously via a
#  launchd agent (see com.rnsts.filemover.plist.template).
# ============================================================

# launchd starts us with a minimal PATH, so make sure Homebrew
# (Apple Silicon or Intel) is reachable for fswatch + python3.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

WATCH_DIR="$HOME/Downloads"
DEST_DIR="$HOME/Documents/finance/statements"
LOG_FILE="$HOME/.config/file-mover/file-mover.log"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/process_statement.py"

# ── Helpers ──────────────────────────────────────────────────

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# ── Process CSV ───────────────────────────────────────────────

process_csv() {
  local filepath="$1"
  local filename
  filename=$(basename "$filepath")
  python3 "$PYTHON_SCRIPT" "$filepath" "$DEST_DIR" "$filename" 2>&1
}

# ── Watch loop ────────────────────────────────────────────────

mkdir -p "$(dirname "$LOG_FILE")"
log "=== File Mover started. Watching: $WATCH_DIR ==="

fswatch -0 --event Created --event Renamed "$WATCH_DIR" | while IFS= read -r -d '' filepath; do

  filename=$(basename "$filepath")

  # Skip hidden / temp files (.crdownload, .part, .com.apple.*)
  [[ "$filename" == .* ]]             && continue
  [[ "$filename" == *.crdownload ]]   && continue
  [[ "$filename" == *.part ]]         && continue

  # ── Rule: contains "Afschriften" or "Statements" ──────────
  if [[ "$filename" == *Afschriften* ]] || [[ "$filename" == *Statements* ]]; then
    log "Matched: $filename"

    # Wait for file to finish writing
    sleep 3

    # Verify file still exists
    [[ ! -f "$filepath" ]] && log "File no longer found: $filepath" && continue

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
