#!/usr/bin/env bash

set -euo pipefail

TITLE='\e[1;37m'
SECTION='\e[1;33m'
KEY='\e[1;32m'
TEXT='\e[0;37m'
DIM='\e[2;37m'
RESET='\e[0m'

draw() {
    clear

    printf "\n"
    printf "  ${TITLE}Frequently Used Keybinds${RESET}\n"
    printf "  ${DIM}Press q, Esc, or Enter to close.${RESET}\n"
    printf "\n"

    printf "  ${SECTION}Apps${RESET}\n"
    printf "    ${KEY}Super + Q${RESET}      ${TEXT}Open terminal${RESET}\n"
    printf "    ${KEY}Super + E${RESET}      ${TEXT}Open file manager${RESET}\n"
    printf "    ${KEY}Super + R${RESET}      ${TEXT}Open app launcher${RESET}\n"
    printf "    ${KEY}Super + L${RESET}      ${TEXT}Lock screen${RESET}\n"
    printf "    ${KEY}Super + Esc${RESET}    ${TEXT}Open power menu${RESET}\n"
    printf "    ${KEY}Super + ?${RESET}      ${TEXT}Open this help${RESET}\n"
    printf "\n"

    printf "  ${SECTION}Windows${RESET}\n"
    printf "    ${KEY}Super + C${RESET}      ${TEXT}Close active window${RESET}\n"
    printf "    ${KEY}Super + V${RESET}      ${TEXT}Toggle floating${RESET}\n"
    printf "    ${KEY}Super + P${RESET}      ${TEXT}Toggle pseudotile${RESET}\n"
    printf "    ${KEY}Super + J${RESET}      ${TEXT}Toggle split direction${RESET}\n"
    printf "    ${KEY}Super + Drag${RESET}   ${TEXT}Move window${RESET}\n"
    printf "    ${KEY}Super + Right Drag${RESET} ${TEXT}Resize window${RESET}\n"
    printf "\n"

    printf "  ${SECTION}Workspaces${RESET}\n"
    printf "    ${KEY}Super + 1..0${RESET}   ${TEXT}Switch workspace${RESET}\n"
    printf "    ${KEY}Super + Shift + 1..0${RESET} ${TEXT}Move window to workspace${RESET}\n"
    printf "    ${KEY}Super + S${RESET}      ${TEXT}Toggle scratchpad workspace${RESET}\n"
    printf "    ${KEY}Super + Shift + S${RESET} ${TEXT}Send window to scratchpad${RESET}\n"
    printf "    ${KEY}Super + Arrow Keys${RESET} ${TEXT}Move focus${RESET}\n"
    printf "    ${KEY}Super + Mouse Wheel${RESET} ${TEXT}Cycle workspaces${RESET}\n"
    printf "\n"

    printf "  ${SECTION}Laptop Keys${RESET}\n"
    printf "    ${KEY}Volume Keys${RESET}    ${TEXT}Volume up, down, mute${RESET}\n"
    printf "    ${KEY}Brightness Keys${RESET} ${TEXT}Brightness up and down${RESET}\n"
    printf "    ${KEY}Media Keys${RESET}     ${TEXT}Previous, play/pause, next${RESET}\n"
    printf "\n"
}

trap 'clear' EXIT
draw

while IFS= read -r -s -n1 key; do
    if [[ "${key}" == $'\x1b' ]]; then
        exit 0
    fi

    case "${key}" in
        q|Q|""|$'\n'|$'\r')
            exit 0
            ;;
    esac
done
