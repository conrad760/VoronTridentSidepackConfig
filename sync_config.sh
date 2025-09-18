#!/bin/bash

# Script to sync Klipper config with GitHub
# Place this in ~/printer_data/config/ on your Pi

REPO_PATH="$HOME/printer_data/config"
cd "$REPO_PATH"

case "$1" in
    push)
        echo "Pushing changes to GitHub..."
        git add .
        git commit -m "${2:-Config update from Pi}"
        git push origin main
        echo "Push complete!"
        ;;
    pull)
        echo "Pulling changes from GitHub..."
        git fetch origin
        git pull origin main
        echo "Pull complete! Restart Klipper if needed."
        ;;
    sync)
        echo "Syncing with GitHub..."
        git add .
        git commit -m "${2:-Config sync from Pi}"
        git pull --rebase origin main
        git push origin main
        echo "Sync complete!"
        ;;
    status)
        git status
        ;;
    *)
        echo "Usage: $0 {push|pull|sync|status} [commit message]"
        echo "  push  - Push local changes to GitHub"
        echo "  pull  - Pull changes from GitHub"
        echo "  sync  - Pull then push (handles conflicts)"
        echo "  status - Show git status"
        exit 1
        ;;
esac