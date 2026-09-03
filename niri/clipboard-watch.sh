#!/usr/bin/env bash

set -euo pipefail

wl-paste --type text --watch cliphist store &
text_pid=$!
wl-paste --type image/png --watch cliphist store &
png_pid=$!
wl-paste --type image/jpeg --watch cliphist store &
jpeg_pid=$!

trap 'kill "$text_pid" "$png_pid" "$jpeg_pid" 2>/dev/null || true' EXIT
wait "$text_pid" "$png_pid" "$jpeg_pid"
