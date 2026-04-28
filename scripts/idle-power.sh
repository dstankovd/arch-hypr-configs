#!/usr/bin/env bash

set -euo pipefail

action="${1:-}"
target="${2:-}"

power_source() {
    local supply type online

    for supply in /sys/class/power_supply/*; do
        [[ -d "${supply}" ]] || continue

        type="$(<"${supply}/type")"
        if [[ "${type}" != "Mains" && "${type}" != "USB" ]]; then
            continue
        fi

        if [[ -r "${supply}/online" ]]; then
            online="$(<"${supply}/online")"
            if [[ "${online}" == "1" ]]; then
                echo "ac"
                return
            fi
        fi
    done

    echo "battery"
}

if [[ -z "${action}" || -z "${target}" ]]; then
    echo "usage: idle-power.sh <dim|off|resume|suspend> <battery|ac>" >&2
    exit 1
fi

if [[ "$(power_source)" != "${target}" ]]; then
    exit 0
fi

case "${action}" in
    dim)
        brightnessctl -s set 10%
        ;;
    off)
        hyprctl dispatch dpms off
        ;;
    resume)
        hyprctl dispatch dpms on
        brightnessctl -r || true
        ;;
    suspend)
        systemctl suspend
        ;;
    *)
        echo "unknown action: ${action}" >&2
        exit 1
        ;;
esac
