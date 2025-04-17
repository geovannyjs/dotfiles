#!/bin/sh

wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -qi muted && echo "[muted]" || echo ""
