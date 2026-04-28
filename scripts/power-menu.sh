#!/bin/bash

options=(suspend hibernate reboot shutdown)
labels=("Suspend" "Hibernate" "Reboot" "Shutdown")

# ANSI colors (uses terminal palette — auto-matches active theme)
BOLD='\e[1;37m'
DIM='\e[2;37m'
RESET='\e[0m'

selected=0

draw() {
    clear
    printf "\n"
    for i in "${!options[@]}"; do
        if [ "$i" = "$selected" ]; then
            printf "  ${BOLD}→ ${labels[$i]}${RESET}\n"
        else
            printf "    ${DIM}${labels[$i]}${RESET}\n"
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
            (( selected < ${#options[@]} - 1 )) && (( selected++ ))
            draw
            ;;
        ""|$'\n'|$'\r')  # Enter
            chosen="${options[$selected]}"
            tput cnorm
            clear
            case "$chosen" in
                suspend)   exec systemctl suspend ;;
                hibernate) exec systemctl hibernate ;;
                reboot)    exec systemctl reboot ;;
                shutdown)  exec systemctl poweroff ;;
            esac
            ;;
        $'\x1b')  # Escape
            exit 0
            ;;
    esac
done