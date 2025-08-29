#!/bin/bash
# qnet.sh — Privacy-hardened network wrapper
# https://github.com/CallMeKadno
# Version 0.1.0
# Usage:
#   sudo ./qnet.sh <mode> [daemon]
#   sudo ./qnet.sh stop

set -euo pipefail

# Configuration
CHECK_INTERVAL=12
KNOWN_DNS="1.1.1.1"
TOR_SOCKS_HOST="127.0.0.1"
TOR_SOCKS_PORT="9050"
TOR_USER="tor"
ALIAS_NAME="qnet"
SCRIPT_PATH="$(realpath "$0")"
MONITORED_OUI_PREFIXES="00:50:56|00:1C:42|00:15:5D|AC:1F:6B"
ALLOW_MONITORED=false
DUMMY_PID=""

# Helper functions
need_root() { [[ "${EUID:-$(id -u)}" -ne 0 ]] && echo "[!] Run as root" && exit 1; }
log() { echo "[$(date '+%H:%M:%S')] $*"; }
notify() { command -v notify-send &>/dev/null && notify-send "Qnet" "$*"; }

ensure_notify_send() {
    if ! command -v notify-send &>/dev/null; then
        log "[*] Installing notify-send..."
        if command -v apt &>/dev/null; then
            apt update -y && apt install -y libnotify-bin || true
        elif command -v dnf &>/dev/null; then
            dnf install -y libnotify || true
        elif command -v pacman &>/dev/null; then
            pacman -S --noconfirm libnotify || true
        fi
    fi
}

ensure_alias() {
    shellrc="$HOME/.bashrc"
    [[ -n "${SUDO_USER:-}" && "$SUDO_USER" != "root" ]] && shellrc="$(getent passwd "$SUDO_USER" | cut -d: -f6)/.bashrc"
    if [[ -f "$shellrc" ]] && ! grep -q "alias $ALIAS_NAME=" "$shellrc"; then
        echo "alias $ALIAS_NAME='sudo $SCRIPT_PATH'" >> "$shellrc"
        log "[*] Alias '$ALIAS_NAME' added to $shellrc"
    fi
}

monitored_network_guard() {
    gw_ip="$(ip route show default | awk '/default/ {print $3}' || true)"
    [[ -z "$gw_ip" ]] && return
    mac="$(ip neigh show | awk -v gw="$gw_ip" '$1==gw {print $5; exit}')"
    if [[ -n "$mac" && "$mac" =~ ^($MONITORED_OUI_PREFIXES) ]]; then
        if ! $ALLOW_MONITORED; then
            notify "Detected monitored network ($mac). Use --allow-monitored to override."
            exit 1
        else
            notify "Proceeding on monitored network (override)."
        fi
    fi
}

flush_rules() {
    iptables -F || true
    iptables -t nat -F || true
    iptables -t mangle -F || true
    iptables -X || true
}

block_local_subnets() {
    iptables -A OUTPUT -d 10.0.0.0/8 -j REJECT
    iptables -A OUTPUT -d 172.16.0.0/12 -j REJECT
    iptables -A OUTPUT -d 192.168.0.0/16 -j REJECT
    iptables -A OUTPUT -d 127.0.0.0/8 -j REJECT
    iptables -A OUTPUT -d 169.254.0.0/16 -j REJECT
    iptables -A OUTPUT -d 224.0.0.0/4 -j REJECT
}

allow_basics_for_tor() {
    iptables -A OUTPUT -o lo -j ACCEPT
    id -u "$TOR_USER" &>/dev/null && iptables -A OUTPUT -m owner --uid-owner "$TOR_USER" -j ACCEPT
}

enforce_all_tcp_via_tor() {
    iptables -t nat -A OUTPUT -p tcp --syn -j REDIRECT --to-ports "$TOR_SOCKS_PORT"
}

kill_switch() {
    log "[!] Kill-switch: blocking all outgoing traffic."
    iptables -P OUTPUT DROP || true
    iptables -P FORWARD DROP || true
    notify "Kill-switch activated: all traffic blocked."
}

restore_policies() {
    iptables -P OUTPUT ACCEPT || true
    iptables -P FORWARD ACCEPT || true
    iptables -P INPUT ACCEPT || true
}

check_public_ip() {
    [[ -n "$(curl -s --max-time 10 https://api.ipify.org || true)" ]]
}

check_dns_resolution() {
    if command -v dig &>/dev/null; then
        dig +short example.com @"$KNOWN_DNS" | grep -qE '^[0-9a-fA-F:.]+$'
    else
        getent ahosts example.com >/dev/null 2>&1
    fi
}

check_tor_ok() {
    curl -s --max-time 12 --socks5-hostname "${TOR_SOCKS_HOST}:${TOR_SOCKS_PORT}" https://check.torproject.org/ \
        | grep -q "Congratulations. This browser is configured to use Tor."
}

start_tor_base() { log "[*] Starting Tor service…"; systemctl start tor; }
start_tor_enforce() { flush_rules; allow_basics_for_tor; block_local_subnets; enforce_all_tcp_via_tor; notify "Tor enforcement active (system-wide TCP)."; }
start_proxychains_notice() { command -v proxychains &>/dev/null && notify "Proxychains ready. Use 'proxychains <app>'."; }
start_protonvpn() { command -v protonvpn &>/dev/null && protonvpn c -f && protonvpn ks --on && notify "ProtonVPN connection established."; }
start_vpn_over_tor() {
    start_tor_base
    if $DAEMON_MODE; then
        start_tor_enforce
    fi
    export http_proxy="socks5h://${TOR_SOCKS_HOST}:${TOR_SOCKS_PORT}"
    export https_proxy="socks5h://${TOR_SOCKS_HOST}:${TOR_SOCKS_PORT}"
    start_protonvpn
    notify "VPN over Tor established."
}

start_padding_noise() {
    (while true; do
        curl -s --max-time 8 --socks5-hostname "${TOR_SOCKS_HOST}:${TOR_SOCKS_PORT}" https://www.debian.org >/dev/null 2>&1 || true
        sleep "$((20 + RANDOM % 50))"
    done) & DUMMY_PID=$!
    log "[*] Padding noise started (pid $DUMMY_PID)."
}

stop_padding_noise() { [[ -n "$DUMMY_PID" ]] && kill "$DUMMY_PID" 2>/dev/null || true; }

handle_failure() {
    local tor_ok="$1"
    if [[ "$tor_ok" == "false" && command -v protonvpn &>/dev/null ]]; then
        log "[*] Fallback to ProtonVPN…"
        notify "Falling back to ProtonVPN."
        start_protonvpn
        return
    fi
    kill_switch
}

stop_qnet() {
    log "[*] Stopping Qnet and cleaning up..."
    stop_padding_noise
    flush_rules
    restore_policies
    systemctl stop tor || true
    command -v protonvpn &>/dev/null && protonvpn d || true
    notify "Qnet stopped. Network restored."
    log "[*] Qnet stopped."
}

monitor_loop() {
    notify "Daemon started. Monitoring leaks…"
    while true; do
        tor_ok="true"
        $CHECK_TOR && ! check_tor_ok && tor_ok="false" && notify "Tor check failed."
        ! check_public_ip && notify "Public IP check failed." && handle_failure "$tor_ok"
        ! check_dns_resolution && notify "DNS resolution failed." && handle_failure "$tor_ok"
        sleep "$CHECK_INTERVAL"
    done
}

# Arg parsing
MODE=""
DAEMON_MODE=false
CHECK_TOR=false

for arg in "$@"; do
    case "$arg" in
        tor|proxy-tor|protonvpn|vpn-over-tor) MODE="$arg" ;;
        daemon) DAEMON_MODE=true ;;
        stop) stop_qnet; exit 0 ;;
        --allow-monitored) ALLOW_MONITORED=true ;;
        *) ;;
    esac
done

[[ -z "$MODE" ]] && MODE="tor"

# Main exe
need_root
ensure_notify_send
ensure_alias
monitored_network_guard
trap 'log "[*] Cleaning up…"; stop_padding_noise; restore_policies; exit 0' INT TERM

case "$MODE" in
    tor)
        start_tor_base
        CHECK_TOR=true
        if $DAEMON_MODE; then
            start_tor_enforce
            start_padding_noise
            notify "Tor daemon active."
            monitor_loop
        else
            notify "Tor manual mode active."
            while true; do
                check_tor_ok || handle_failure "false"
                sleep "$CHECK_INTERVAL"
            done
        fi
        ;;
    proxy-tor)
        start_tor_base
        CHECK_TOR=true
        start_proxychains_notice
        if $DAEMON_MODE; then
            start_tor_enforce
            start_padding_noise
            notify "Proxychains→Tor daemon active."
            monitor_loop
        else
            notify "Proxychains→Tor manual mode ready."
            while true; do
                check_tor_ok || handle_failure "false"
                sleep "$CHECK_INTERVAL"
            done
        fi
        ;;
    protonvpn)
        start_protonvpn
        while true; do
            ! check_public_ip || ! check_dns_resolution && notify "Leak detected under ProtonVPN." && kill_switch
            sleep "$CHECK_INTERVAL"
        done
        ;;
    vpn-over-tor)
        CHECK_TOR=true
        start_vpn_over_tor
        if $DAEMON_MODE; then
            start_padding_noise
            notify "VPN-over-Tor daemon active."
            monitor_loop
        else
            notify "VPN-over-Tor manual active."
            while true; do
                check_tor_ok || handle_failure "false"
                sleep "$CHECK_INTERVAL"
            done
        fi
        ;;
    *)
        log "[!] Unknown mode: $MODE"
        exit 1
        ;;
esac