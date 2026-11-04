#!/usr/bin/env bash
#
# SlimBrave-Mac
# An open-source debloater for Brave Browser on macOS.
# Inspired by ltx0101/SlimBrave (Windows) and adapted natively for macOS enterprise policies.
#
# License: GPL-3.0
# Repository: https://github.com/your-username/SlimBrave-Mac
#

set -eo pipefail

VERSION="1.0.0"
PLIST_DIR="/Library/Managed Preferences"
BUNDLE_ID="com.brave.Browser"
PLIST_PATH="${PLIST_DIR}/${BUNDLE_ID}.plist"

# Formatting & Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

print_banner() {
    clear 2>/dev/null || true
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
  ____  _ _           ____                              __  __             
 / ___|| (_)_ __ ___ | __ ) _ __ __ ___   _____        |  \/  | __ _  ___ 
 \___ \| | | '_ ` _ \|  _ \| '__/ _` \ \ / / _ \ _____ | |\/| |/ _` |/ __|
  ___) | | | | | | | | |_) | | | (_| |\ V /  __/_____| |  | | (_| | (__ 
 |____/|_|_|_| |_| |_|____/|_|  \__,_| \_/ \___|       |_|  |_|\__,_|\___|
EOF
    echo -e "${NC}"
    echo -e "${MAGENTA}${BOLD}   SlimBrave for macOS${NC} ${DIM}v${VERSION}${NC} - Native Brave Browser Debloater"
    echo -e "${DIM}   Safe, non-destructive debloating via Chromium Enterprise Policies${NC}"
    echo "────────────────────────────────────────────────────────────────────────"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}${BOLD}[!] Administrator privileges required.${NC}"
        echo -e "    Please run this script with sudo: ${YELLOW}sudo bash $0${NC}\n"
        exit 1
    fi
}

detect_brave() {
    local found=0
    if [[ -d "/Applications/Brave Browser.app" ]]; then
        found=1
    elif [[ -d "$HOME/Applications/Brave Browser.app" ]]; then
        found=1
    fi

    if [[ $found -eq 0 ]]; then
        echo -e "${YELLOW}[!] Warning: Brave Browser was not found in standard application folders.${NC}"
        echo -e "    Policies will still be applied to bundle ID '${BUNDLE_ID}'.\n"
    fi
}

write_policy_plist() {
    local preset_name="$1"
    shift
    local -a keys=("$@")

    echo -e "${BLUE}[*] Writing configuration to ${CYAN}${PLIST_PATH}${NC}..."
    mkdir -p "${PLIST_DIR}"

    # Build XML plist
    local temp_plist
    temp_plist=$(mktemp /tmp/brave_policy.XXXXXX)

    cat << 'PLIST_HEAD' > "$temp_plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
PLIST_HEAD

    for item in "${keys[@]}"; do
        IFS=":" read -r key type val <<< "$item"
        echo "    <key>${key}</key>" >> "$temp_plist"
        if [[ "$type" == "bool" ]]; then
            echo "    <${val}/>" >> "$temp_plist"
        elif [[ "$type" == "int" ]]; then
            echo "    <integer>${val}</integer>" >> "$temp_plist"
        elif [[ "$type" == "string" ]]; then
            echo "    <string>${val}</string>" >> "$temp_plist"
        fi
    done

    cat << 'PLIST_TAIL' >> "$temp_plist"
</dict>
</plist>
PLIST_TAIL

    # Validate XML syntax with Apple plutil
    if plutil -lint "$temp_plist" >/dev/null 2>&1; then
        mv "$temp_plist" "$PLIST_PATH"
        chmod 644 "$PLIST_PATH"
        chown root:wheel "$PLIST_PATH"
        echo -e "${GREEN}${BOLD}[✓] Successfully applied '${preset_name}' preset!${NC}\n"
    else
        echo -e "${RED}[✗] Generated plist failed validation! Aborting.${NC}"
        rm -f "$temp_plist"
        exit 1
    fi
}

apply_full_debloat() {
    print_banner
    echo -e "${BOLD}Applying Preset: ${CYAN}Full / Ultra Debloat${NC}\n"
    
    local policies=(
        "BraveWalletDisabled:bool:true"
        "BraveRewardsDisabled:bool:true"
        "BraveAIChatEnabled:bool:false"
        "BraveVPNDisabled:bool:true"
        "BraveTalkDisabled:bool:true"
        "BraveNewsDisabled:bool:true"
        "TorDisabled:bool:true"
        "BraveP3AEnabled:bool:false"
        "BraveStatsPingEnabled:bool:false"
        "MetricsReportingEnabled:bool:false"
        "BraveWebDiscoveryEnabled:bool:false"
        "BraveWaybackMachineEnabled:bool:false"
        "BraveSpeedreaderEnabled:bool:false"
    )

    write_policy_plist "Full Debloat" "${policies[@]}"
    print_summary "Full Debloat"
}

apply_balanced() {
    print_banner
    echo -e "${BOLD}Applying Preset: ${CYAN}Balanced Privacy & Clean UI${NC}\n"

    local policies=(
        "BraveWalletDisabled:bool:true"
        "BraveRewardsDisabled:bool:true"
        "BraveAIChatEnabled:bool:false"
        "BraveVPNDisabled:bool:true"
        "BraveTalkDisabled:bool:true"
        "BraveNewsDisabled:bool:true"
        "TorDisabled:bool:true"
        "BraveP3AEnabled:bool:false"
        "BraveStatsPingEnabled:bool:false"
        "MetricsReportingEnabled:bool:false"
        "BraveWebDiscoveryEnabled:bool:false"
    )

    write_policy_plist "Balanced Privacy" "${policies[@]}"
    print_summary "Balanced Privacy"
}

apply_performance() {
    print_banner
    echo -e "${BOLD}Applying Preset: ${CYAN}Performance Focused${NC}\n"

    local policies=(
        "BraveWalletDisabled:bool:true"
        "BraveRewardsDisabled:bool:true"
        "BraveAIChatEnabled:bool:false"
        "BraveVPNDisabled:bool:true"
        "BraveNewsDisabled:bool:true"
        "TorDisabled:bool:true"
        "BraveP3AEnabled:bool:false"
        "BraveStatsPingEnabled:bool:false"
        "MetricsReportingEnabled:bool:false"
    )

    write_policy_plist "Performance Focused" "${policies[@]}"
    print_summary "Performance Focused"
}

revert_policies() {
    print_banner
    echo -e "${BOLD}Reverting policies...${NC}\n"

    if [[ -f "$PLIST_PATH" ]]; then
        rm -f "$PLIST_PATH"
        echo -e "${GREEN}[✓] Removed ${PLIST_PATH}${NC}"
        echo -e "${GREEN}${BOLD}[✓] All Brave policies have been reset to factory defaults!${NC}\n"
    else
        echo -e "${YELLOW}[!] No policy file found at ${PLIST_PATH}.${NC}"
        echo -e "    Brave is already running with default settings.\n"
    fi
    restart_instruction
}

check_status() {
    print_banner
    echo -e "${BOLD}Current Debloat Policy Status:${NC}\n"

    if [[ ! -f "$PLIST_PATH" ]]; then
        echo -e "  Status: ${YELLOW}No managed preferences active (Stock Brave)${NC}"
        echo -e "  File:   ${DIM}${PLIST_PATH} (does not exist)${NC}\n"
        return
    fi

    echo -e "  Status: ${GREEN}Active policies detected${NC}"
    echo -e "  File:   ${CYAN}${PLIST_PATH}${NC}\n"
    echo -e "  ${BOLD}Configured Keys:${NC}"

    local keys=(
        "BraveWalletDisabled"
        "BraveRewardsDisabled"
        "BraveAIChatEnabled"
        "BraveVPNDisabled"
        "BraveTalkDisabled"
        "BraveNewsDisabled"
        "TorDisabled"
        "BraveP3AEnabled"
        "BraveStatsPingEnabled"
        "MetricsReportingEnabled"
        "BraveWebDiscoveryEnabled"
        "BraveWaybackMachineEnabled"
        "BraveSpeedreaderEnabled"
    )

    for key in "${keys[@]}"; do
        val=$(/usr/libexec/PlistBuddy -c "Print :${key}" "$PLIST_PATH" 2>/dev/null || echo "not set")
        if [[ "$val" == "true" ]]; then
            printf "    %-28s : ${GREEN}%s${NC}\n" "$key" "ENABLED"
        elif [[ "$val" == "false" ]]; then
            printf "    %-28s : ${RED}%s${NC}\n" "$key" "DISABLED"
        else
            printf "    %-28s : ${DIM}%s${NC}\n" "$key" "Not Set (Default)"
        fi
    done
    echo ""
}

print_summary() {
    local preset="$1"
    echo -e "${CYAN}Preset Summary for '${preset}':${NC}"
    echo "  • Crypto Wallet (Web3, dApps)  : Disabled"
    echo "  • Brave Rewards & BAT system    : Disabled"
    echo "  • Leo AI Chat Assistant         : Disabled"
    echo "  • Brave VPN promotions          : Disabled"
    echo "  • Brave News on New Tab         : Disabled"
    echo "  • Background Telemetry / P3A    : Disabled"
    echo "  • Stats active-user ping        : Disabled"
    echo ""
    restart_instruction
}

restart_instruction() {
    echo -e "${YELLOW}${BOLD}Important Next Steps:${NC}"
    echo -e "  1. Completely quit Brave (${BOLD}⌘ + Q${NC})."
    echo -e "  2. Relaunch Brave Browser."
    echo -e "  3. Verify policies by typing ${BOLD}brave://policy${NC} in the address bar."
    echo -e "  4. (Note: Seeing ${DIM}'Managed by your organization'${NC} in Settings is normal and indicates success!)\n"
}

interactive_menu() {
    print_banner
    detect_brave

    echo -e "${BOLD}Please choose an option:${NC}\n"
    echo -e "  ${GREEN}1)${NC} ${BOLD}Full / Ultra Debloat${NC}       - Disables all crypto, AI, news, VPN, tor & telemetry"
    echo -e "  ${BLUE}2)${NC} ${BOLD}Balanced Privacy Preset${NC}    - Strips bloat & telemetry, preserves Wayback & Speedreader"
    echo -e "  ${MAGENTA}3)${NC} ${BOLD}Performance Focused${NC}        - Strips bloat, background services & metrics"
    echo -e "  ${CYAN}4)${NC} ${BOLD}Check Status${NC}               - View currently active policies"
    echo -e "  ${YELLOW}5)${NC} ${BOLD}Revert to Default${NC}          - Remove all custom policies"
    echo -e "  ${RED}6)${NC} ${BOLD}Exit${NC}\n"

    read -rp "Enter choice [1-6]: " choice
    echo ""

    case "$choice" in
        1) apply_full_debloat ;;
        2) apply_balanced ;;
        3) apply_performance ;;
        4) check_status ;;
        5) revert_policies ;;
        6) echo "Exiting."; exit 0 ;;
        *) echo -e "${RED}Invalid selection.${NC}"; exit 1 ;;
    esac
}

# CLI Argument Parsing
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]]; then
    print_banner
    echo "Usage: sudo ./SlimBrave.sh [OPTION]"
    echo ""
    echo "Options:"
    echo "  -f, --full         Apply Full Debloat preset"
    echo "  -b, --balanced     Apply Balanced Privacy preset"
    echo "  -p, --performance  Apply Performance preset"
    echo "  -s, --status       Check currently active policies"
    echo "  -r, --revert       Remove all policies and restore defaults"
    echo "  -h, --help         Display this help message"
    echo ""
    echo "Run without arguments for interactive menu."
    exit 0
fi

check_root

case "${1:-}" in
    --full|-f|full)
        apply_full_debloat
        ;;
    --balanced|-b|balanced)
        apply_balanced
        ;;
    --performance|-p|performance)
        apply_performance
        ;;
    --status|-s|status)
        check_status
        ;;
    --revert|-r|revert)
        revert_policies
        ;;
    --help|-h|help)
        print_banner
        echo "Usage: sudo ./SlimBrave.sh [OPTION]"
        echo ""
        echo "Options:"
        echo "  -f, --full         Apply Full Debloat preset"
        echo "  -b, --balanced     Apply Balanced Privacy preset"
        echo "  -p, --performance  Apply Performance preset"
        echo "  -s, --status       Check currently active policies"
        echo "  -r, --revert       Remove all policies and restore defaults"
        echo "  -h, --help         Display this help message"
        echo ""
        echo "Run without arguments for interactive menu."
        ;;
    "")
        interactive_menu
        ;;
    *)
        echo -e "${RED}Unknown argument: $1${NC}"
        echo "Run '$0 --help' for available options."
        exit 1
        ;;
esac
