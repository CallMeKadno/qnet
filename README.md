<!-- banner  -->
<img width="1400" height="514" alt="banner" src="https://github.com/user-attachments/assets/58e95210-ce99-46d2-9beb-de2d07ab8f6b" />

<!-- badges  -->
<p align="center">
  <!-- OS badge -->
  <img src="https://img.shields.io/badge/Linux-Debian-informational?logo=debian&logoColor=white&color=A80030" alt="Debian Linux" />
  <!-- Python badge -->
  <img src="https://img.shields.io/badge/Python-3.x-FFDB51?logo=python&logoColor=white" alt="Python 3" />
  <!-- Bash badge -->
  <img src="https://img.shields.io/badge/Bash-Scripting-44B351?logo=gnubash&logoColor=white" alt="Bash" />
  <!-- Batch badge with high-quality white Windows 11 logo -->
  <img src="https://img.shields.io/badge/Batch-Windows-3EBDF3?logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3QgeD0iMyIgeT0iMyIgd2lkdGg9IjgiIGhlaWdodD0iOCIgcng9IjEiIHN0cm9rZT0iI2ZmZiIgc3Ryb2tlLXdpZHRoPSIyIi8+CjxyZWN0IHg9IjEzIiB5PSIzIiB3aWR0aD0iOCIgaGVpZ2h0PSI4IiByeD0iMSIgc3Ryb2tlPSIjZmZmIiBzdHJva2Utd2lkdGg9IjIiLz4KPHJlY3QgeD0iMyIgeT0iMTMiIHdpZHRoPSI4IiBoZWlnaHQ9IjgiIHJ4PSIxIiBzdHJva2U9IiNmZmYiIHN0cm9rZS13aWR0aD0iMiIvPgo8cmVjdCB4PSIxMyIgeT0iMTMiIHdpZHRoPSI4IiBoZWlnaHQ9IjgiIHJ4PSIxIiBzdHJva2U9IiNmZmYiIHN0cm9rZS13aWR0aD0iMiIvPgo8L3N2Zz4K" alt="Batch Script" />
<!-- Cyber Security badge -->
<img src="https://img.shields.io/badge/Cyber%20Security-Specialist-white?logo=hackthebox&logoColor=white&style=flat&labelText=Cyber%20Security&message=Specialist&messageColor=000000" alt="Cyber Security" />
</p>

I'm Kadno, a developer and cyber security analyst with a passion for building secure software and programs, _particularly command line tools_.

<br>
<!-- CODE KADNO -->
<p align="center">
  <a href="https://git.io/typing-svg">
    <img src="https://readme-typing-svg.demolab.com?font=Orbitron&pause=1000&color=DCDCDC&center=true&vCenter=true&width=435&size=50&lines=CODE+KADNO" alt="Typing SVG" />
  </a>
</p>

# ⛓️ <a href="https://git.io/typing-svg"><img src="https://readme-typing-svg.demolab.com?font=Orbitron&pause=1000&color=DCDCDC&vCenter=true&width=435&height=20&lines=%3E_++RUN+QNET" alt="Typing SVG" /></a>
A simple Privacy-Hardened Network Wrapper for Linux systems. Qnet is designed to route your traffic through **Tor, VPN, or both**, with system-wide enforcement, leak detection, and kill-switch protection out of the box.
With support for manual and daemon modes, proxychains integration, and provides notifications for important events for both DE (Desktop Environment) and headless (Server) infrastructures.

## Features

- System-wide **Tor routing** with optional proxychains chaining.
- **ProtonVPN** support, including VPN-over-Tor mode.
- **Daemon mode** for continuous monitoring and automatic kill-switch enforcement.
- **Leak detection**: monitors public IP, DNS, and Tor connectivity.
- **Kill-switch**: blocks all outgoing traffic if a leak is detected.
- **Padding noise**: optional traffic padding in daemon modes to obscure patterns.
- **Local subnet blocking**: prevents traffic to LAN or reserved subnets while active.
- **Notifications** via `notify-send` for start, stop, leaks, and kill-switch events.
- **Alias setup**: automatically adds `qnet` alias on first run.

## Installation

1. Clone the repository:

```bash
git clone https://github.com/CallMeKadno/qnet.git
cd qnet
chmod +x qnet.sh
```

2. Usage:
`sudo ./qnet.sh <mode> [daemon]`

| Mode                | Description                                                                              |
| ------------------- | ---------------------------------------------------------------------------------------- |
| `tor`               | Manual Tor mode; routes apps through Tor.                                                |
| `proxy-tor`         | Manual mode: use `proxychains <app>` > Tor. Daemon enforces all TCP via Tor.             |
| `protonvpn`         | Connects via ProtonVPN; monitors leaks and triggers kill-switch if needed.               |
| `vpn-over-tor`      | Connects Tor first, then ProtonVPN over Tor; protects identity with multiple layers.     |
| `daemon`            | Append to any mode to enable background monitoring and automatic enforcement.            |
| `stop`              | Stops Qnet, flushes firewall rules, stops Tor/ProtonVPN, and restores normal networking. |
| `--allow-monitored` | Override monitored network guard for restricted networks (e.g., corporate/VM networks).  |


Whilst it shouldn't need saying, this is the internet and people often download and pray:
- Local subnet blocking only applies while Qnet is running. When stopped, LAN and normal networking is restored.
- Padding noise adds dummy traffic to obscure patterns but is optional.
- Avoid running Tor/VPN from monitored networks (corporate, university) unless using `--allow-monitored`.
- Tor and VPNs are not silver bullets. Consider multiple layers for maximum privacy (e.g., VPN-over-Tor).
- **Do not rely on Qnet alone** for end-to-end anonymity; always combine with safe browsing habits.

## License

<img src="https://mirrors.creativecommons.org/presskit/icons/cc.svg" alt="" style="max-width: 1em;max-height:1em;margin-left: .2em;"><img src="https://mirrors.creativecommons.org/presskit/icons/by.svg" alt="" style="max-width: 1em;max-height:1em;margin-left: .2em;"><img src="https://mirrors.creativecommons.org/presskit/icons/nc.svg" alt="" style="max-width: 1em;max-height:1em;margin-left: .2em;"><img src="https://mirrors.creativecommons.org/presskit/icons/nd.svg" alt="" style="max-width: 1em;max-height:1em;margin-left: .2em;">
<br><a href="https://github.com/CallMeKadno/QNet">QNet</a> © 2025 by <a href="https://github.com/CallMeKadno">Charles aka 'Kadno' </a> is licensed under <a href="https://creativecommons.org/licenses/by-nc-nd/4.0/">CC BY-NC-ND 4.0</a>
<br>
<p align="center"><small><i>This is a beta README and is subject to change</i></small></p>