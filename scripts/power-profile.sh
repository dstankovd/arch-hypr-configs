#!/bin/bash

# Profiles: display label → powerprofilesctl name
declare -A LABELS=(
    [performance]="Performance"
    [balanced]="Balanced"
    [power-saver]="Power Saver"
)
profiles=(performance balanced power-saver)

# ANSI colors (uses terminal palette — auto-matches active theme)
YELLOW='\e[33m'
BOLD_YELLOW='\e[1;33m'
DIM='\e[2;37m'
BOLD='\e[1;37m'
RESET='\e[0m'

current="$(powerprofilesctl get)"

# Start cursor on the active profile
selected=0
for i in "${!profiles[@]}"; do
    [ "${profiles[$i]}" = "$current" ] && selected=$i && break
done

draw() {
    clear
    printf "\n"
    for i in "${!profiles[@]}"; do
        local id="${profiles[$i]}"
        local label="${LABELS[$id]}"
        local is_active=false
        local is_cursor=false
        [ "$id" = "$current" ]   && is_active=true
        [ "$i"  = "$selected" ]  && is_cursor=true

        if $is_cursor && $is_active; then
            printf "  ${BOLD_YELLOW}→ ${label} ●${RESET}\n"
        elif $is_cursor; then
            printf "  ${BOLD}→ ${label}${RESET}\n"
        elif $is_active; then
            printf "    ${YELLOW}${label} ●${RESET}\n"
        else
            printf "    ${DIM}${label}${RESET}\n"
        fi
    done
    printf "\n"
}

tput civis
trap 'tput cnorm; clear' EXIT

draw

KEY=""
while true; do
    IFS= read -r -s -n1 KEY
    if [[ "$KEY" == $'\x1b' ]]; then
        read -r -s -n2 -t 0.1 rest
        KEY="${KEY}${rest}"
    fi

    case "$KEY" in
        $'\x1b[A')  # Up
            (( selected > 0 )) && (( selected-- ))
            draw
            ;;
        $'\x1b[B')  # Down
            (( selected < ${#profiles[@]} - 1 )) && (( selected++ ))
            draw
            ;;
        ""|$'\n'|$'\r')  # Enter
            chosen="${profiles[$selected]}"
            tput cnorm
            clear
            if [ "$chosen" != "$current" ]; then
                echo "Applying: ${LABELS[$chosen]}"
                powerprofilesctl set "$chosen"
            fi
            exit 0
            ;;
        $'\x1b')  # Escape
            exit 0
            ;;
    esac
done