#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONFIGS_DIR="${REPO_ROOT}/configs"
TARGET_ROOT="${HOME}/.config"
BACKUP_ROOT="${HOME}/.config_bkp"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

apply_gtk_theme() {
    local settings_file="${TARGET_ROOT}/gtk-3.0/settings.ini"
    local gtk_theme
    local icon_theme
    local color_scheme

    if ! command -v gsettings >/dev/null 2>&1; then
        echo "skip  gtk theme apply -> gsettings not available"
        return
    fi

    if [[ ! -f "${settings_file}" ]]; then
        echo "skip  gtk theme apply -> missing ${settings_file}"
        return
    fi

    gtk_theme="$(awk -F= '/^gtk-theme-name=/{print $2; exit}' "${settings_file}")"
    icon_theme="$(awk -F= '/^gtk-icon-theme-name=/{print $2; exit}' "${settings_file}")"

    if [[ -z "${gtk_theme}" ]]; then
        echo "skip  gtk theme apply -> no gtk-theme-name in ${settings_file}"
        return
    fi

    color_scheme="prefer-light"
    if [[ "${gtk_theme,,}" == *dark* ]]; then
        color_scheme="prefer-dark"
    fi

    if gsettings set org.gnome.desktop.interface gtk-theme "${gtk_theme}" 2>/dev/null; then
        echo "apply gtk-theme -> ${gtk_theme}"
    else
        echo "skip  gtk theme apply -> failed to set gtk-theme" >&2
        return
    fi

    if ! gsettings set org.gnome.desktop.interface color-scheme "${color_scheme}" 2>/dev/null; then
        echo "skip  gtk color-scheme apply -> failed to set ${color_scheme}" >&2
    else
        echo "apply color-scheme -> ${color_scheme}"
    fi

    if [[ -n "${icon_theme}" ]]; then
        if gsettings set org.gnome.desktop.interface icon-theme "${icon_theme}" 2>/dev/null; then
            echo "apply icon-theme -> ${icon_theme}"
        else
            echo "skip  gtk icon apply -> failed to set ${icon_theme}" >&2
        fi
    fi
}

if [[ ! -d "${CONFIGS_DIR}" ]]; then
    echo "Missing configs directory: ${CONFIGS_DIR}" >&2
    exit 1
fi

mkdir -p "${BACKUP_ROOT}" "${TARGET_ROOT}"

find "${CONFIGS_DIR}" -mindepth 1 -maxdepth 1 -printf '%P\n' | sort | while IFS= read -r name; do
    case "${name}" in
        README|README.*|*.md)
            continue
            ;;
    esac

    src="${CONFIGS_DIR}/${name}"
    dest="${TARGET_ROOT}/${name}"
    backup="${BACKUP_ROOT}/${name}_${TIMESTAMP}"

    if [[ -L "${dest}" && "$(readlink "${dest}")" == "${src}" ]]; then
        echo "skip  ${name} -> already linked"
        continue
    fi

    if [[ -e "${dest}" || -L "${dest}" ]]; then
        mv "${dest}" "${backup}"
        echo "backup ${dest} -> ${backup}"
    fi

    ln -s "${src}" "${dest}"
    echo "link   ${dest} -> ${src}"
done

SCRIPTS_SRC="${REPO_ROOT}/scripts"
SCRIPTS_DEST="${TARGET_ROOT}/scripts"
SCRIPTS_BACKUP="${BACKUP_ROOT}/scripts_${TIMESTAMP}"

if [[ -d "${SCRIPTS_SRC}" ]]; then
    if [[ -L "${SCRIPTS_DEST}" && "$(readlink "${SCRIPTS_DEST}")" == "${SCRIPTS_SRC}" ]]; then
        echo "skip  scripts -> already linked"
    else
        if [[ -e "${SCRIPTS_DEST}" || -L "${SCRIPTS_DEST}" ]]; then
            mv "${SCRIPTS_DEST}" "${SCRIPTS_BACKUP}"
            echo "backup ${SCRIPTS_DEST} -> ${SCRIPTS_BACKUP}"
        fi

        ln -s "${SCRIPTS_SRC}" "${SCRIPTS_DEST}"
        echo "link   ${SCRIPTS_DEST} -> ${SCRIPTS_SRC}"
    fi
fi

apply_gtk_theme
