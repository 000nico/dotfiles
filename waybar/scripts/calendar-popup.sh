#!/usr/bin/env bash

set -euo pipefail

cal -3 | fuzzel --dmenu --anchor top-right --width 42 --lines 12 --prompt "calendar> "
