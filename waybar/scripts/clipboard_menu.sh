#!/bin/bash
cliphist list | wofi --dmenu --width 700 --height 400 | cliphist decode | wl-copy
