#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="/home/ngan/nixos-config"
LOG_DIR="/var/log/nixos-rebuild"
KEEP_LOGS=20

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

rotate_logs() {
    local files
    files=$(ls -1t "$LOG_DIR"/rebuild-*.log "$LOG_DIR"/rebuild-FAILED-*.log 2>/dev/null || true)
    if [ -z "$files" ]; then
        return
    fi
    local count
    count=$(echo "$files" | wc -l)
    if [ "$count" -gt "$KEEP_LOGS" ]; then
        echo "$files" | tail -n +$((KEEP_LOGS + 1)) | xargs -r rm -f
    fi
}

cd "$CONFIG_DIR"

mkdir -p "$LOG_DIR"

echo -e "${BOLD}=== Changes ===${NC}"
CHANGED=0
if ! git diff --cached --quiet --exit-code 2>/dev/null; then
    CHANGED=1
fi
if ! git diff --quiet --exit-code 2>/dev/null; then
    CHANGED=1
fi
if git ls-files --others --exclude-standard 2>/dev/null | grep -q .; then
    CHANGED=1
fi

if [ "$CHANGED" -eq 1 ]; then
    git status --short
    echo
    git diff --color=always HEAD
    git diff --color=always --cached
else
    echo -e "${YELLOW}No changes detected.${NC}"
fi

echo
read -r -p "$(echo -e "${BOLD}Proceed with rebuild? [y/N]${NC} ")" CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

TIMESTAMP=$(date +%s)
TMP_LOG="$LOG_DIR/rebuild-$TIMESTAMP.tmp.log"

echo
echo -e "${BOLD}=== Building ===${NC}"

set +e +o pipefail
git add -A
sudo nixos-rebuild switch --flake "$CONFIG_DIR#nixos" &> "$TMP_LOG"
BUILD_EXIT=$?
set -e -o pipefail

if [ "$BUILD_EXIT" -eq 0 ]; then
    GEN=$(sudo nixos-rebuild list-generations | grep -w True | awk '{print $1}')
    mv "$TMP_LOG" "$LOG_DIR/rebuild-$GEN.log"

    git commit -m "generation $GEN"

    rotate_logs

    echo
    echo -e "${GREEN}${BOLD}Rebuild successful (generation $GEN)${NC}"
    echo "Log: $LOG_DIR/rebuild-$GEN.log"
else
    FAILED_LOG="$LOG_DIR/rebuild-FAILED-$TIMESTAMP.log"
    mv "$TMP_LOG" "$FAILED_LOG"

    rotate_logs

    echo
    echo -e "${RED}${BOLD}=== Build failed ===${NC}"
    echo
    echo -e "${BOLD}Errors:${NC}"
    grep -iE '^\s*error:' "$FAILED_LOG" | sort -u || true
    echo
    echo "Full log: $FAILED_LOG"
    exit 1
fi