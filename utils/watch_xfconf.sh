#!/usr/bin/env bash
# Kill all background monitoring processes when you press Ctrl+C
trap 'pkill -P $$' EXIT

echo "Monitoring all Xfconf channels... (Press Ctrl+C to stop)"

for channel in $(xfconf-query -l | grep -v '^Channels:'); do
    xfconf-query -c "$channel" -m -v | sed "s/^/[$channel] /" &
done

wait
