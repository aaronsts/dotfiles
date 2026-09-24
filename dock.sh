#!/usr/bin/env bash
#
# Reset the Dock to a curated set of apps. Edit the APPS list to taste and
# re-run — it's idempotent (wipes the Dock, then adds these in order).
# Run as your normal user (no sudo — dockutil edits *your* Dock).

set -e

if ! command -v dockutil >/dev/null 2>&1; then
  echo "dockutil not found — add it to the Brewfile and run brew bundle."
  exit 1
fi

echo "▶ Resetting the Dock…"

# Apps to pin, left-to-right. Add/remove lines freely.
APPS=(
  "/Applications/Ghostty.app"
  "/Applications/Firefox.app"
  "/Applications/Visual Studio Code.app"
  "/Applications/Bitwarden.app"
)

dockutil --remove all --no-restart
sleep 2   # give the Dock a moment to settle before re-adding

for app in "${APPS[@]}"; do
  if [ -e "$app" ]; then
    dockutil --add "$app" --no-restart
    echo "  added   $(basename "$app" .app)"
  else
    echo "  skipped (not installed): $(basename "$app" .app)"
  fi
done

killall Dock
