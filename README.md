# SlimBrave-Mac 🦁⚡

> **A native, open-source macOS debloater for Brave Browser.** Strip away crypto wallets, rewards, Leo AI, VPN ads, news feeds, and background telemetry using official Apple Managed Preferences & Chromium Enterprise Policies.

[![License: GPL-3.0](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS-lightgrey.svg)](https://apple.com)
[![Safe & Non-Destructive](https://img.shields.io/badge/Method-Enterprise%20Policies-success.svg)](#how-it-works)

Inspired by the original [ltx0101/SlimBrave](https://github.com/ltx0101/SlimBrave) utility for Windows, **SlimBrave-Mac** provides the same debloating capabilities natively tailored for macOS.

---

## 🚀 Quick Start (One-Liner)

Open your macOS Terminal and run:

```bash
curl -fsSL https://raw.githubusercontent.com/iamujjwalsinha/SlimBrave-Mac/main/SlimBrave.sh -o /tmp/SlimBrave.sh && sudo bash /tmp/SlimBrave.sh
```

Or clone the repo locally:

```bash
git clone https://github.com/iamujjwalsinha/SlimBrave-Mac.git
cd SlimBrave-Mac
sudo ./SlimBrave.sh
```

---

## ✨ Features Debloated

| Category | Component | Policy Key | Full | Balanced | Performance |
| :--- | :--- | :--- | :---: | :---: | :---: |
| 🪙 **Crypto / Web3** | Brave Crypto Wallet | `BraveWalletDisabled` | ❌ | ❌ | ❌ |
| 🪙 **Crypto / Web3** | Brave Rewards & BAT Token | `BraveRewardsDisabled` | ❌ | ❌ | ❌ |
| 🤖 **AI Assistant** | Leo AI Sidebar & Omnibox | `BraveAIChatEnabled` | ❌ | ❌ | ❌ |
| 🛡️ **Promotions** | Brave VPN Upsells | `BraveVPNDisabled` | ❌ | ❌ | ❌ |
| 📞 **Services** | Brave Talk Call Prompts | `BraveTalkDisabled` | ❌ | ❌ | — |
| 📰 **Content** | Brave News on New Tab | `BraveNewsDisabled` | ❌ | ❌ | ❌ |
| 🧅 **Network** | Tor Integration & Daemons | `TorDisabled` | ❌ | ❌ | ❌ |
| 📊 **Telemetry** | Product Analytics (P3A) | `BraveP3AEnabled` | ❌ | ❌ | ❌ |
| 📊 **Telemetry** | Active Users Stats Ping | `BraveStatsPingEnabled` | ❌ | ❌ | ❌ |
| 📊 **Telemetry** | Chromium Crash/Metrics | `MetricsReportingEnabled` | ❌ | ❌ | ❌ |
| 🌐 **Search** | Web Discovery Project | `BraveWebDiscoveryEnabled` | ❌ | ❌ | — |
| 🏛️ **Utilities** | Wayback Machine Prompts | `BraveWaybackMachineEnabled`| ❌ | — | — |
| 📖 **Utilities** | Speedreader View | `BraveSpeedreaderEnabled` | ❌ | — | — |

*(❌ = Disabled / Bloat Removed | — = Preserved / Left Default)*

---

## 🎛️ Presets

1. **Full / Ultra Debloat (`--full`)**:
   Completely strips all bloat, integrations, AI, and telemetry. Ideal for users who want pure, lightning-fast Chromium with Brave's ad-blocking shields and nothing else.

2. **Balanced Privacy (`--balanced`)**:
   Removes crypto, rewards, AI, VPN promos, and telemetry while keeping convenience utilities like Wayback Machine and Speedreader.

3. **Performance Focused (`--performance`)**:
   Targets memory-heavy and network-polling background services, freeing RAM and CPU cycles.

---

## 🛠️ CLI Options

SlimBrave-Mac can be run interactively or automated via command-line arguments:

```bash
sudo ./SlimBrave.sh --full         # Apply Full Debloat
sudo ./SlimBrave.sh --balanced     # Apply Balanced Privacy
sudo ./SlimBrave.sh --performance  # Apply Performance Focused
sudo ./SlimBrave.sh --status       # Inspect currently applied policies
sudo ./SlimBrave.sh --revert       # Revert all changes back to factory defaults
sudo ./SlimBrave.sh --help         # Show help menu
```

---

## 🔍 How It Works

Unlike brittle browser hacks, SlimBrave-Mac **never modifies binary files, app bundles, or code signatures**.

Instead, it writes official Chromium administrative configuration to:
`/Library/Managed Preferences/com.brave.Browser.plist`

- **Update-Proof**: Browser updates will not break or undo your configuration.
- **100% Reversible**: Running `sudo ./SlimBrave.sh --revert` deletes the plist and immediately restores stock settings.
- **Verification**: After applying, restart Brave (`⌘ + Q`) and visit `brave://policy` to inspect active policies.

> **Note**: In Brave's settings menu, you will see a badge stating *"Managed by your organization"*. This is standard Chromium behavior whenever system policies are configured.

---

## 🤝 Contributing

Contributions, bug reports, and suggestions are warmly welcome!
Please check out [CONTRIBUTING.md](CONTRIBUTING.md) to get started.

---

## 📜 License

Distributed under the **GNU General Public License v3.0** (GPL-3.0). See [LICENSE](LICENSE) for details.

### Acknowledgments
- Inspired by [ltx0101/SlimBrave](https://github.com/ltx0101/SlimBrave) for Windows.
