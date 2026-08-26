#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="/var/log/nixos-rebuild"
KEEP_LOGS=20
GIT_NAME="NganPham334"
GIT_EMAIL="189833900+NganPham334@users.noreply.github.com"

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

cd /etc/nixos

mkdir -p "$LOG_DIR"

echo -e "${BOLD}=== Changes ===${NC}"
CHANGED=0
if ! sudo git diff --cached --quiet --exit-code 2>/dev/null; then
    CHANGED=1
fi
if ! sudo git diff --quiet --exit-code 2>/dev/null; then
    CHANGED=1
fi
if sudo git ls-files --others --exclude-standard 2>/dev/null | grep -q .; then
    CHANGED=1
fi

if [ "$CHANGED" -eq 1 ]; then
    sudo git status --short
    echo
    sudo git diff --color=always HEAD
    sudo git diff --color=always --cached
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
sudo nixos-rebuild switch 2>&1 | tee "$TMP_LOG"
BUILD_EXIT=${PIPESTATUS[0]}
set -e -o pipefail

if [ "$BUILD_EXIT" -eq 0 ]; then
    GEN=$(sudo nixos-rebuild list-generations | tail -1 | awk '{print $1}')
    mv "$TMP_LOG" "$LOG_DIR/rebuild-$GEN.log"

    sudo git add -A
    sudo git -c "user.name=$GIT_NAME" -c "user.email=$GIT_EMAIL" commit -m "generation $GEN"

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