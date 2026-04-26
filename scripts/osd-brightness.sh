#!/usr/bin/env bash

set -euo pipefail

action="${1:?missing action}"

if swayosd-client --brightness "${action}"; then
    exit 0
fi

case "${action}" in
    raise)
        brightnessctl -e4 -n2 set 5%+
        ;;
    lower)
        brightnessctl -e4 -n2 set 5%-
        ;;
    *)
        echo "Unsupported brightness action: ${action}" >&2
        exit 1
        ;;
esac
