#!/usr/bin/env bash

set -euo pipefail

action="${1:-mute-toggle}"

if swayosd-client --input-volume "${action}"; then
    exit 0
fi

case "${action}" in
    mute-toggle)
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        ;;
    *)
        echo "Unsupported mic action: ${action}" >&2
        exit 1
        ;;
esac
