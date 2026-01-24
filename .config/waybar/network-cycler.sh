#!/usr/bin/env bash
# Waybar Network Interface Cycler
# Scroll through network interfaces using wheel

# Configuration
STATE_DIR="$HOME/.config/waybar/state"
STATE_FILE="$STATE_DIR/network-cycler.idx"
SKIP_INTERFACES="lo docker0 veth*"  # interfaces to skip

# Create state directory if it doesn't exist
mkdir -p "$STATE_DIR"

# Get list of all network interfaces (excluding loopback and virtual interfaces)
get_interfaces() {
    local interfaces=()

    for iface in /sys/class/net/*; do
        local ifname=$(basename "$iface")

        # Skip loopback, docker, and veth interfaces
        for skip in $SKIP_INTERFACES; do
            if [[ "$ifname" == $skip ]]; then
                continue 2
            fi
        done

        interfaces+=("$ifname")
    done

    # Sort interfaces (prefer enp* over wlp* over others)
    echo "${interfaces[@]}"
}

# Get current interface index from state file
get_current_index() {
    if [[ -f "$STATE_FILE" ]]; then
        cat "$STATE_FILE"
    else
        echo "0"
    fi
}

# Save current interface index
save_index() {
    echo "$1" > "$STATE_FILE"
}

navigate() {
    local direction="$1"
    interfaces=($(get_interfaces))
    count=${#interfaces[@]}

    if [[ $count -eq 0 ]]; then
        return
    fi

    current_index=$(get_current_index)
    if [[ "$direction" == "next" ]]; then
        next_index=$(( (current_index + 1) % count ))
    else
        next_index=$(( (current_index - 1 + count) % count ))
    fi

    save_index "$next_index"
}

# Get current interface index from state file
get_current_index() {
    if [[ -f "$STATE_FILE" ]]; then
        cat "$STATE_FILE"
    else
        echo "0"
    fi
}

# Save current interface index
save_index() {
    echo "$1" > "$STATE_FILE"
}

# Get network information for an interface
get_network_info() {
    local iface="$1"
    local total="$2"
    local current_idx="$3"

    local ipaddr=""
    local cidr=""
    local status="down"
    local icon=""
    local text=""
    local tooltip=""

    if [[ ! -d "/sys/class/net/$iface" ]]; then
        echo '{"text": "'"$iface"' ❌", "class": "disabled", "tooltip": "Interface not found"}'
        return
    fi

    local operstate=$(cat "/sys/class/net/$iface/operstate" 2>/dev/null)
    if [[ "$operstate" == "up" || "$operstate" == "unknown" ]]; then
        status="up"
    fi

    if [[ "$status" == "up" ]]; then
        local ip_info=$(ip addr show "$iface" 2>/dev/null | grep 'inet ' | head -n 1)
        if [[ -n "$ip_info" ]]; then
            ipaddr=$(echo "$ip_info" | awk '{print $2}')
            cidr=$(echo "$ip_info" | awk '{print $2}' | cut -d'/' -f1)
        fi
    fi

    local iftype=""
    if [[ "$iface" == enp* || "$iface" == eth* ]]; then
        iftype="ethernet"
        icon="󰊗"
    elif [[ "$iface" == wlp* || "$iface" == wlan* || "$iface" == wwl* ]]; then
        iftype="wifi"
        if [[ "$status" == "up" ]]; then
            local signal=$(iwconfig "$iface" 2>/dev/null | grep 'Signal level' | awk -F'[=]' '{print $3}' | awk '{print int($1)}')
            if [[ -n "$signal" && "$signal" -gt 0 ]]; then
                icon=""
                local essid=$(iwgetid -r "$iface" 2>/dev/null)
                if [[ -n "$essid" ]]; then
                    text="$essid ($signal%) $icon"
                else
                    text="$iface $icon"
                fi
            else
                text="$iface $icon"
            fi
        else
            text="$iface "
        fi
    else
        iftype="other"
        icon=""
    fi

    if [[ "$status" == "up" && -n "$cidr" ]]; then
        if [[ "$iftype" == "ethernet" ]]; then
            text="$iface: $cidr $icon"
        fi
        tooltip="Interface: $iface\nType: $iftype\nIP: $ipaddr\nStatus: Connected"
    elif [[ "$status" == "up" ]]; then
        text="$iface (No IP) "
        tooltip="Interface: $iface\nType: $iftype\nStatus: Connected (No IP)"
    else
        text="$iface "
        tooltip="Interface: $iface\nType: $iftype\nStatus: Disconnected"
    fi

    echo "{\"text\": \"$text [$((current_idx + 1))/$total]\", \"class\": \"$iftype $status\", \"tooltip\": \"$tooltip\"}"
}

interfaces=($(get_interfaces))
count=${#interfaces[@]}

if [[ $count -eq 0 ]]; then
    echo '{"text": "No interfaces", "class": "disabled"}'
    exit 0
fi

case "$1" in
    "--next")
        navigate "next"
        ;;
    "--prev")
        navigate "prev"
        ;;
esac

current_index=$(get_current_index)
if [[ $current_index -ge $count ]]; then
    current_index=0
    save_index "$current_index"
fi

current_iface="${interfaces[$current_index]}"
get_network_info "$current_iface" "$count" "$current_index"
