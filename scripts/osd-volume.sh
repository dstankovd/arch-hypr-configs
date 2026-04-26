#!/usr/bin/env bash

set -euo pipefail

action="${1:?missing action}"

if swayosd-client --output-volume "${action}"; then
    exit 0
fi

case "${action}" in
    raise)
        wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
        ;;
    lower)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        ;;
    mute-toggle)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
    *)
        echo "Unsupported volume action: ${action}" >&2
        exit 1
        ;;
esac
