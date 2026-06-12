#!/usr/bin/env bash

# =====================================================
echo "SIMPLE LINUX TOOLKIT by BENSON NGUGI"
# =====================================================

# -------------------------
# COLORS
# -------------------------
RED="\e[32m"
GREEN="\e[31m"
YELLOW="\e[36m"
BLUE="\e[30m"
CYAN="\e[35m"
BOLD="\e[1m"
RESET="\e[0m"

# -------------------------
# CONFIG
# -------------------------
CONFIG_FILE="$HOME/.godtoolkit.conf"
LOG_FILE="$HOME/godtoolkit.log"
PLUGIN_DIR="./plugins"

mkdir -p "$PLUGIN_DIR"

# -------------------------
# LOGGING (AUDIT MODE)
# -------------------------
log_action() {
    echo "[$(date)] $1" >> "$LOG_FILE"
}

# -------------------------
# LOAD CONFIG
# -------------------------
load_config() {
    [[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"
}

# -------------------------
# ARROW KEY HANDLER
# -------------------------
get_key() {
    IFS= read -rsn1 key
    if [[ $key == $'\x1b' ]]; then
        read -rsn2 key
        case $key in
            "[A") echo UP ;;
            "[B") echo DOWN ;;
            "[C") echo RIGHT ;;
            "[D") echo LEFT ;;
        esac
    else
        echo "$key"
    fi
}

# -------------------------
# UI DRAW
# -------------------------
draw_menu() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "======================================"
    echo "  SIMPLE TOOLKIT CLI by BENSON NGUGI"
    echo "======================================"
    echo -e "${RESET}"

    options=("File Organizer" "File Search" "🖥 System Dashboard" "Plugins" "Logs" "Exit")

    for i in "${!options[@]}"; do
        if [[ $i -eq $selected ]]; then
            echo -e "${GREEN}➤ ${options[$i]}${RESET}"
        else
            echo "  ${options[$i]}"
        fi
    done
}

# -------------------------
# Main function of this script.Hizi zingine ni madoido
# -------------------------
file_organizer() {
    local dir="${1:-.}"
    local hash_db="$dir/.hashdb"

    echo -e "${BLUE}Running File Organizer Now...${RESET}"
    log_action "File organizer has started"

    for file in "$dir"/*; do
        [[ -f "$file" ]] || continue

        hash=$(md5sum "$file" | awk '{print $1}')

        if grep -q "$hash" "$hash_db" 2>/dev/null; then
            mkdir -p "$dir/Duplicates"
            mv "$file" "$dir/Duplicates/"
            log_action "Duplicate moved: $file"
            continue
        else
            echo "$hash" >> "$hash_db"
        fi

        case "${file,,}" in
            *.jpg|*.png|*.jpeg) mkdir -p "$dir/Images"; mv "$file" "$dir/Images/" ;;
            *.mp4) mkdir -p "$dir/Videos"; mv "$file" "$dir/Videos/" ;;
            *.mp3) mkdir -p "$dir/Audio"; mv "$file" "$dir/Audio/" ;;
            *.txt) mkdir -p "$dir/Text"; mv "$file" "$dir/Text/" ;;
            *.sh) mkdir -p "$dir/Scripts"; mv "$file" "$dir/Scripts/" ;;
            *) mkdir -p "$dir/Others"; mv "$file" "$dir/Others/" ;;
        esac

        log_action "Moved: $file"
    done

    echo -e "${GREEN}Done.${RESET}"
    read -rp "Press Enter..."
}

# -------------------------
# This is for the system info.Just simple commands pekee
# -------------------------
system_dashboard() {
    clear
    echo -e "${CYAN}${BOLD}SYSTEM DASHBOARD${RESET}"
    echo "----------------------------------"

    echo -e "User      : $(whoami)"
    echo -e "Date      : $(date)"
    echo -e "Uptime    : $(uptime -p)"
    echo -e "CPU Load  : $(cat /proc/loadavg | awk '{print $1, $2, $3}')"
    echo -e "Memory    : $(free -h | awk 'NR==2{print $3 "/" $2}')"
    echo -e "Disk      : $(df -h / | awk 'NR==2{print $3 "/" $2}')"

    echo ""
    echo "Top Processes:"
    ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -6

    log_action "Viewed system dashboard"
    read -rp "Press Enter..."
}

# -------------------------
# FILE SEARCH
# -------------------------
file_search() {
    read -rp "Directory: " dir
    read -rp "Keyword: " kw

    log_action "Search: $kw in $dir"

    grep -Rni "$kw" "$dir"
    read -rp "Press Enter...lazima uambiwe?"
}

# -------------------------
# PLUGIN SYSTEM
# -------------------------
load_plugins() {
    for plugin in "$PLUGIN_DIR"/*.sh; do
        [[ -f "$plugin" ]] && source "$plugin"
    done
}

plugins_menu() {
    clear
    echo -e "${CYAN}PLUGINS${RESET}"
    echo "--------------------"

    for plugin in "$PLUGIN_DIR"/*.sh; do
        [[ -f "$plugin" ]] || continue
        echo "Loaded: $(basename "$plugin")"
    done

    echo ""
    echo "Drop .sh files into plugins/ folder"
    read -rp "Press Enter..."
}

# -------------------------
# main loop--with terminal user interface (TUI)
# -------------------------
selected=0
options_count=6

load_config
load_plugins

while true; do
    draw_menu
    key=$(get_key)

    case $key in
        UP)
            ((selected--))
            ((selected < 0)) && selected=$((options_count-1))
            ;;
        DOWN)
            ((selected++))
            ((selected >= options_count)) && selected=0
            ;;
        "")
            case $selected in
                0) file_organizer ;;
                1) file_search ;;
                2) system_dashboard ;;
                3) plugins_menu ;;
                4) tail -n 20 "$LOG_FILE"; read -rp "Press Enter..." ;;
		5) echo -e "${RED}Exiting...Bye welcome back again if interested not a must;)${RESET}"; exit 0 ;;
            esac
            ;;
    esac
done
