#!/bin/bash

# Get supported powerctl
if command -v powerprofilesctl &>/dev/null; then
  powerctl="powerprofilesctl"
elif command -v asusctl &>/dev/null; then
  powerctl="asusctl"
else
  powerctl=""
fi

# Get current power profile
get_current_profile() {
  case "$powerctl" in
  "powerprofilesctl")
    powerprofilesctl get
    ;;
  "asusctl")
    local current_mode=$(asusctl profile get | awk '/^Active profile: /{print tolower($NF); exit}')
    if [ "$current_mode" = "quiet" ]; then
      current_mode="power-saver"
    fi
    echo "$current_mode"
    ;;
  *)
    echo "power-saver" # fallback
    ;;
  esac
}

# Set power profile
set_profile() {
  local mode="$1"
  if [ "$powerctl" = "powerprofilesctl" ]; then
    if command -v powerprofilesctl &>/dev/null; then
      powerprofilesctl set "$mode"
    fi
  elif [ "$powerctl" = "asusctl" ]; then
    if [ "$1" = "power-saver" ]; then
      mode="quiet"
    fi
    if command -v asusctl &>/dev/null; then
      asusctl profile set "$mode"
    fi
  fi
}

# Toggle between profiles
toggle_profile() {
  current=$(get_current_profile)
  case "$current" in
  "power-saver")
    set_profile "balanced"
    ;;
  "balanced")
    set_profile "performance"
    ;;
  "performance")
    set_profile "power-saver"
    ;;
  *)
    set_profile "balanced"
    ;;
  esac
}

# Display current profile with icon only
display_profile() {
  current=$(get_current_profile)
  case $current in
  "power-saver")
    echo "󰾆" # Battery/efficiency icon
    ;;
  "balanced")
    echo "󰾅" # Balanced icon
    ;;
  "performance")
    echo "󰓅" # Performance/rocket icon
    ;;
  esac
}

# Handle arguments
case "${1:-display}" in
"toggle")
  toggle_profile
  display_profile
  ;;
"display" | *)
  display_profile
  ;;
esac
exit 0
