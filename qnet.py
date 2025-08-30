#!/usr/bin/env python3
# qnet.py - Privacy-hardened network wrapper
# https://github.com/CallMeKadno
# Version 0.3.5
import subprocess
import sys
import time
import os
import signal
import atexit
import random
import threading

TOR_SERVICE = "tor@default"
TRANS_PORT = 9040
DNS_PORT = 5353
SOCKS_PORT = 9050

REQUIRED_PACKAGES = ["tor", "torsocks", "curl"]

SCUFFING_ENABLED = True
SCUFF_INTERVAL = 0.5
 # Add more URLs here for scuffing
SCUFF_URLS = [
    "https://check.torproject.org/",
    "https://www.mozilla.org/",
    "https://www.python.org/",
    "https://www.github.com/",
    "https://www.stackoverflow.com/",
    "https://www.reddit.com/",
    "https://www.medium.com/",
    "https://www.linkedin.com/",
    "https://www.netflix.com/",
    "https://www.spotify.com/",
    "https://www.imdb.com/",
    "https://www.wikipedia.org/",
    "https://www.quora.com/",
    "https://www.amazon.com/",
    "https://www.ebay.com/",
    "https://www.twitter.com/",
    "https://www.instagram.com/",
    "https://www.twitch.tv/",
    "https://www.nytimes.com/",
    "https://www.bbc.com/",
    "https://www.cnn.com/",
    "https://www.hulu.com/",
    "https://www.discord.com/",
    "https://www.pinterest.com/",
    "https://www.stackexchange.com/",
    "https://www.shopify.com/",
    "https://www.slack.com/",
    "https://www.tiktok.com/",
    "https://www.paypal.com/",
    "https://www.airbnb.com/",
    "https://www.booking.com/",
    "https://www.etsy.com/",
    "https://www.zoom.us/",
    "https://www.dropbox.com/",
    "https://www.salesforce.com/",
    "https://www.adobe.com/",
    "https://www.cloudflare.com/",
    "https://www.nike.com/",
    "https://www.apple.com/",
    "https://www.microsoft.com/",
    "https://www.spotify.com/",
    "https://www.snapchat.com/",
    "https://www.kickstarter.com/",
    "https://www.canva.com/",
    "https://www.trello.com/"
]

def run(cmd, check=True):
    try:
        return subprocess.run(cmd, shell=True, check=check)
    except subprocess.CalledProcessError as e:
        print(f"[!] Command failed: {e.cmd}")
        if check:
            sys.exit(1)

def install_packages(packages):
    missing = []
    for pkg in packages:
        result = subprocess.run(f"dpkg -s {pkg}", shell=True,
                                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if result.returncode != 0:
            missing.append(pkg)
    if missing:
        print(f"[*] Installing missing packages: {', '.join(missing)}")
        run(f"sudo apt update && sudo apt install -y {' '.join(missing)}")

def fix_torsocks_conf():
    conf_file = "/etc/tor/torsocks.conf"
    try:
        if os.path.exists(conf_file):
            with open(conf_file, "r") as f:
                lines = f.readlines()
            new_lines = [l for l in lines if not l.strip().startswith("server") and not l.strip().startswith("server_port")]
            with open(conf_file, "w") as f:
                f.writelines(new_lines)
            print("[*] Cleaned torsocks config to suppress warnings")
    except Exception as e:
        print(f"[!] Could not clean torsocks.conf: {e}")

def check_tor_browser():
    result = subprocess.run("which tor-browser", shell=True, capture_output=True, text=True)
    if result.returncode == 0:
        return
    snap_installed = subprocess.run("which snap", shell=True, capture_output=True, text=True)
    if snap_installed.returncode == 0:
        print("[*] Installing Tor Browser via Snap...")
        try:
            run("sudo snap install tor-browser")
        except subprocess.CalledProcessError:
            print("[!] Failed to install Tor Browser via Snap. Install manually.")
    else:
        print("[!] Snap is not installed. Cannot auto-install Tor Browser. Install manually if needed.")

def start_tor():
    print("[*] Starting Tor service...")
    run(f"sudo systemctl start {TOR_SERVICE}")
    time.sleep(2)
    print("[*] Tor service started successfully.")

def stop_tor():
    print("[*] Stopping Tor service...")
    run(f"sudo systemctl stop {TOR_SERVICE}")
    flush_iptables()
    print("[*] Tor stopped and network restored.")

def flush_iptables():
    run("sudo iptables -F")
    run("sudo iptables -t nat -F")

def setup_transparent_routing():
    print("[*] Setting up system-wide transparent Tor routing...")
    flush_iptables()
    run("sudo iptables -t nat -A OUTPUT -d 127.0.0.1/8 -j RETURN")
    run(f"sudo iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports {DNS_PORT}")
    run(f"sudo iptables -t nat -A OUTPUT -p tcp --syn -j REDIRECT --to-ports {TRANS_PORT}")
    print("[✓] Transparent Tor routing enabled for all users.")

def check_tor_ports():
    print("[*] Checking if Tor ports are open...")
    tcp_result = subprocess.run(["ss", "-ltn"], capture_output=True, text=True)
    if f"127.0.0.1:{TRANS_PORT}" not in tcp_result.stdout:
        print(f"[!] Tor TransPort {TRANS_PORT} is not open. Exiting.")
        sys.exit(1)
    print(f"[*] Tor TransPort {TRANS_PORT} is open.")
    udp_result = subprocess.run(["ss", "-lun"], capture_output=True, text=True)
    if f"127.0.0.1:{DNS_PORT}" not in udp_result.stdout:
        print(f"[!] Tor DNSPort {DNS_PORT} is not open. Exiting.")
        sys.exit(1)
    print(f"[*] Tor DNSPort {DNS_PORT} is open.")

def check_tor_connection():
    print("[*] Checking Tor connection via SOCKS5...")
    try:
        result = subprocess.run(
            ["curl", "--socks5", f"127.0.0.1:{SOCKS_PORT}", "-s", "https://check.torproject.org/api/ip"],
            capture_output=True, text=True
        )
        if '"IsTor":true' in result.stdout:
            print("[✓] Tor is working! Traffic is routed through Tor.")
        else:
            print("[!] Tor check failed. Traffic may not be routed through Tor.")
    except Exception as e:
        print(f"[!] Error during Tor connection check: {e}")

def launch_tor_browser():
    print("[*] Launching Tor Browser...")
    try:
        run("tor-browser")
    except FileNotFoundError:
        print("[!] Tor Browser not found. Install manually or via Snap.")

def send_scuffing():
    try:
        url = random.choice(SCUFF_URLS)
        subprocess.run(
            ["torsocks", "curl", "-s", url],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
    except Exception:
        pass

def tor_command_shell():
    print("[*] Entering Tor command shell. Type 'exit' to quit.")
    print("[!] Only TCP traffic is routed through Tor. ICMP (ping) and UDP-only tools may not work.")
    user = os.environ.get('SUDO_USER', os.environ.get('USER', 'user'))
    cwd = os.getcwd()
    while True:
        try:
            cmd = input(f"\n[!][{user}@{os.path.basename(cwd)}]$ ").strip()
            if cmd.lower() in ("exit", "quit"):
                break
            if not cmd:
                continue

            if SCUFFING_ENABLED:
                num_threads = random.randint(1, 5)
                for _ in range(num_threads):
                    scuff_thread = threading.Thread(target=send_scuffing, daemon=True)
                    scuff_thread.start()
                time.sleep(SCUFF_INTERVAL)

            subprocess.run(f"torsocks {cmd}", shell=True, stderr=subprocess.DEVNULL)
        except KeyboardInterrupt:
            print()
        except Exception as e:
            print(f"[!] Error running command: {e}")

def main():
    if os.geteuid() != 0:
        print("[!] This script must be run as root (sudo).")
        sys.exit(1)
    args = sys.argv[1:]
    launch_browser_flag = "-browser" in args
    launch_shell_flag = "-shell" in args
    install_packages(REQUIRED_PACKAGES)
    fix_torsocks_conf()
    if launch_browser_flag:
        check_tor_browser()
    atexit.register(flush_iptables)
    atexit.register(stop_tor)
    signal.signal(signal.SIGINT, lambda sig, frame: sys.exit(0))
    start_tor()
    check_tor_ports()
    check_tor_connection()
    if launch_shell_flag:
        tor_command_shell()
        return
    setup_transparent_routing()
    if launch_browser_flag:
        launch_tor_browser()
    print("\n[*] System-wide Tor routing is active for all users.")
    print("[*] Press Ctrl+C to stop and restore network settings.\n")
    try:
        while True:
            time.sleep(10)
    except KeyboardInterrupt:
        print("\n[*] Exiting Tor script...")
        sys.exit(0)

if __name__ == "__main__":
    main()
