#!/usr/bin/env bash

set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "${SCRIPT_PATH}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TARGET_DIR="${HOME}/.config/wallpaper"
STATE_FILE="${TARGET_DIR}/current"

usage() {
    cat <<'EOF'
Usage:
  set-wallpaper.sh <wallpaper-path>
  set-wallpaper.sh --restore

Examples:
  set-wallpaper.sh wallpapers/board.png
  set-wallpaper.sh /path/to/image.png
EOF
}

apply_wallpaper() {
    local image_path="${1}"

    if ! command -v swaybg >/dev/null 2>&1; then
        echo "swaybg is required but not installed." >&2
        exit 1
    fi

    pkill -x swaybg >/dev/null 2>&1 || true
    nohup swaybg -i "${image_path}" -m fill >/dev/null 2>&1 &
}

restore_wallpaper() {
    if [[ ! -s "${STATE_FILE}" ]]; then
        echo "No saved wallpaper state at ${STATE_FILE}" >&2
        exit 0
    fi

    local saved_path
    saved_path="$(<"${STATE_FILE}")"

    if [[ ! -f "${saved_path}" ]]; then
        echo "Saved wallpaper not found: ${saved_path}" >&2
        exit 1
    fi

    apply_wallpaper "${saved_path}"
}

main() {
    if [[ $# -ne 1 ]]; then
        usage >&2
        exit 1
    fi

    case "${1}" in
        --restore)
            restore_wallpaper
            exit 0
            ;;
        -h|--help)
            usage
            exit 0
            ;;
    esac

    local source_path="${1}"
    if [[ ! -f "${source_path}" ]]; then
        source_path="${REPO_ROOT}/${1}"
    fi

    if [[ ! -f "${source_path}" ]]; then
        echo "Wallpaper path not found: ${1}" >&2
        exit 1
    fi
    source_path="$(readlink -f "${source_path}")"

    mkdir -p "${TARGET_DIR}"

    local file_name target_path
    file_name="$(basename "${source_path}")"
    target_path="${TARGET_DIR}/${file_name}"

    cp "${source_path}" "${target_path}"
    printf '%s\n' "${target_path}" > "${STATE_FILE}"

    apply_wallpaper "${target_path}"
    echo "Wallpaper set: ${target_path}"
}

main "$@"
