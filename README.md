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
A simple Privacy-Hardened Network Wrapper for Linux systems. Qnet is designed to route your traffic through **Tor, VPN, or both**, with system-wide enforcement, leak detection, and kill-switch protection out of the box - *some features still in development after porting to python though*. With upcoming proxychains support and notifications for important events for both DE (_Desktop Environment_) and headless (_Server_) infrastructures.

## Features
- System-wide **Tor routing** for all users
- **Tor command shell** where every command automatically uses `torsocks` (TCP only)
- **Tor command shell padding noise** for extra obscurity at random
- **Tor Browser integration** with automatic launch if installed
- **Dependency management**: automatically installs missing packages (`tor`, `torsocks`, `curl`)
- **torsocks configuration cleanup** to suppress warnings
- **New-line input in shell** ensures each command is executed on a fresh line
- **Automatic cleanup**: restores iptables and stops Tor service on exit

## Installation

1. Clone the repository:

```bash
git clone https://github.com/CallMeKadno/qnet.git
cd qnet
```

2. Usage:
`sudo python3 ./qnet.py {-arg}`

| Mode           | Description                                                                                  |
|----------------|----------------------------------------------------------------------------------------------|
| `-shell`       | Opens a Tor-enabled command shell; Commands automatically go through `torsocks`. TCP only.   |
| `-browser`     | Launches Tor Browser with Tor routing active. Strongly encouraged.                           |
| default        | Enables system-wide Tor routing for all users. Some browsers based on `chromium` bypass this!|
| `stop`         | Stops Qnet, flushes iptables, stops the Tor service, and restores normal networking.         |

Whilst it shouldn't need saying, this is the internet and people often download and pray:
- Local subnet blocking only applies while Qnet is running. When stopped, LAN and normal networking is restored.
- Padding noise adds dummy traffic to obscure patterns in the `-shell` option.
- Avoid running Tor/VPN from monitored networks (corporate, university) for obvious reasons.
- Tor and VPNs are not silver bullets. Consider multiple layers for maximum privacy (e.g., VPN-over-Tor).
- **Do not rely on Qnet alone** for end-to-end anonymity; always combine with safe browsing habits.

## License

<img src="https://mirrors.creativecommons.org/presskit/icons/cc.svg" alt="" style="max-width: 1em;max-height:1em;margin-left: .2em;"><img src="https://mirrors.creativecommons.org/presskit/icons/by.svg" alt="" style="max-width: 1em;max-height:1em;margin-left: .2em;"><img src="https://mirrors.creativecommons.org/presskit/icons/nc.svg" alt="" style="max-width: 1em;max-height:1em;margin-left: .2em;"><img src="https://mirrors.creativecommons.org/presskit/icons/nd.svg" alt="" style="max-width: 1em;max-height:1em;margin-left: .2em;">
<br><a href="https://github.com/CallMeKadno/qnet">Qnet</a> © 2025 by <a href="https://github.com/CallMeKadno">Charles aka 'Kadno' </a> is licensed under <a href="https://creativecommons.org/licenses/by-nc-nd/4.0/">CC BY-NC-ND 4.0</a>
<br>
<p align="center"><small><i>This is a beta README and is subject to change</i></small></p>
