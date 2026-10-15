#!/usr/bin/env bash
# Kill all background monitoring processes when you press Ctrl+C
trap 'pkill -P $$' EXIT

declare -A seen

watch_new_channels() {
    for channel in $(xfconf-query -l | grep -v '^Channels:'); do
        [[ -n ${seen[$channel]} ]] && continue
        seen[$channel]=1
        xfconf-query -c "$channel" -m -v | sed "s/^/[$channel] /" &
    done
}

echo "Monitoring all Xfconf channels... (Press Ctrl+C to stop)"

watch_new_channels
sleep 0.5
clear

# Rescan for channels that appeared later, silently
while true; do
    sleep 5
    watch_new_channels
done