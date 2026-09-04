#!/usr/bin/env bash

set -u

readonly FIFO="/tmp/cava.fifo"
readonly LOG_DIR="$HOME/.cache/niri"
readonly WAVE="$HOME/.config/niri/cava-wave.py"
readonly CAVA_CONFIG="$HOME/.config/cava/config"

mkdir -p "$LOG_DIR"
rm -f "$FIFO"

if command -v swww-daemon >/dev/null 2>&1 && ! ps -eo comm= | grep -qx "swww-daemon"; then
    swww-daemon >"$LOG_DIR/swww.log" 2>&1 &
fi

cleanup() {
    [[ -n "${cava_pid:-}" ]] && kill "$cava_pid" 2>/dev/null || true
    [[ -n "${wave_pid:-}" ]] && kill "$wave_pid" 2>/dev/null || true
    [[ -n "${waybar_pid:-}" ]] && kill "$waybar_pid" 2>/dev/null || true
    rm -f "$FIFO"
}
trap cleanup EXIT INT TERM HUP

"$WAVE" >"$LOG_DIR/cava-wave.log" 2>&1 &
wave_pid=$!
sleep 0.5
cava -p "$CAVA_CONFIG" >"$LOG_DIR/cava.log" 2>&1 &
cava_pid=$!
sleep 0.3
waybar >"$LOG_DIR/waybar.log" 2>&1 &
waybar_pid=$!
wait "$wave_pid"
