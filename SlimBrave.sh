#!/usr/bin/env bash
#
# SlimBrave-Mac
# An open-source debloater for Brave Browser on macOS.
# Inspired by ltx0101/SlimBrave (Windows) and adapted natively for macOS.
#
# License: GPL-3.0
# Repository: https://github.com/your-username/SlimBrave-Mac
#

set -eo pipefail

VERSION="1.1.0"
BUNDLE_ID="com.brave.Browser"
SYSTEM_PLIST_DIR="/Library/Managed Preferences"
SYSTEM_PLIST_PATH="${SYSTEM_PLIST_DIR}/${BUNDLE_ID}.plist"

# Mode: user (defaults write, NO SUDO needed) or system (managed preferences, requires sudo)
IS_ROOT=0
if [[ $EUID -eq 0 ]]; then
    IS_ROOT=1
fi

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
    cat << "BANNER"
  ____  _ _           ____                              __  __             
 / ___|| (_)_ __ ___ | __ ) _ __ __ ___   _____        |  \/  | __ _  ___ 
 \___ \| | | '_ ` _ \|  _ \| '__/ _` \ \ / / _ \ _____ | |\/| |/ _` |/ __|
  ___) | | | | | | | | |_) | | | (_| |\ V /  __/_____| |  | | (_| | (__ 
 |____/|_|_|_| |_| |_|____/|_|  \__,_| \_/ \___|       |_|  |_|\__,_|\___|
BANNER
    echo -e "${NC}"
    echo -e "${MAGENTA}${BOLD}   SlimBrave for macOS${NC} ${DIM}v${VERSION}${NC} - Native Brave Browser Debloater"
    if [[ $IS_ROOT -eq 1 ]]; then
        echo -e "   Running in: ${YELLOW}System Mode (Root / Managed Preferences)${NC}"
    else
        echo -e "   Running in: ${GREEN}User Mode (No sudo required!)${NC}"
    fi
    echo "────────────────────────────────────────────────────────────────────────"
}

detect_brave() {
    local found=0
    if [[ -d "/Applications/Brave Browser.app" ]] || [[ -d "$HOME/Applications/Brave Browser.app" ]]; then
        found=1
    fi

    if [[ $found -eq 0 ]]; then
        echo -e "${YELLOW}[!] Note: Brave Browser was not found in standard /Applications folders.${NC}"
        echo -e "    Preferences will still be written for bundle ID '${BUNDLE_ID}'.\n"
    fi
}

apply_policies_to_target() {
    local preset_name="$1"
    shift
    local -a keys=("$@")

    echo -e "${BLUE}[*] Applying '${preset_name}' policies...${NC}"

    if [[ $IS_ROOT -eq 1 ]]; then
        # Write to /Library/Managed Preferences
        mkdir -p "${SYSTEM_PLIST_DIR}"
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

        if plutil -lint "$temp_plist" >/dev/null 2>&1; then
            mv "$temp_plist" "$SYSTEM_PLIST_PATH"
            chmod 644 "$SYSTEM_PLIST_PATH"
            chown root:wheel "$SYSTEM_PLIST_PATH"
            echo -e "${GREEN}${BOLD}[✓] Written to System Managed Preferences: ${SYSTEM_PLIST_PATH}${NC}\n"
        else
            echo -e "${RED}[✗] Plist validation failed!${NC}"
            rm -f "$temp_plist"
            exit 1
        fi
    else
        # Write using user-level defaults write (No sudo needed!)
        for item in "${keys[@]}"; do
            IFS=":" read -r key type val <<< "$item"
            defaults write "${BUNDLE_ID}" "${key}" -"${type}" "${val}"
        done
        echo -e "${GREEN}${BOLD}[✓] Written to User Preferences domain: ${BUNDLE_ID}${NC}\n"
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

    apply_policies_to_target "Full Debloat" "${policies[@]}"
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

    apply_policies_to_target "Balanced Privacy" "${policies[@]}"
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

    apply_policies_to_target "Performance Focused" "${policies[@]}"
    print_summary "Performance Focused"
}

revert_policies() {
    print_banner
    echo -e "${BOLD}Reverting policies...${NC}\n"

    # 1. System plist
    if [[ -f "$SYSTEM_PLIST_PATH" ]]; then
        if [[ $IS_ROOT -eq 1 ]]; then
            rm -f "$SYSTEM_PLIST_PATH"
            echo -e "${GREEN}[✓] Removed system policy file: ${SYSTEM_PLIST_PATH}${NC}"
        else
            echo -e "${YELLOW}[!] System policy file exists at ${SYSTEM_PLIST_PATH}. Run with sudo to remove it.${NC}"
        fi
    fi

    # 2. User defaults
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
        defaults delete "${BUNDLE_ID}" "${key}" 2>/dev/null || true
    done

    echo -e "${GREEN}${BOLD}[✓] All Brave policies have been reset to factory defaults!${NC}\n"
    restart_instruction
}

check_status() {
    print_banner
    echo -e "${BOLD}Current Debloat Policy Status:${NC}\n"

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
        local val=""
        # Check system managed preferences first
        if [[ -f "$SYSTEM_PLIST_PATH" ]]; then
            val=$(/usr/libexec/PlistBuddy -c "Print :${key}" "$SYSTEM_PLIST_PATH" 2>/dev/null || true)
        fi
        # Check user domain if not in system
        if [[ -z "$val" ]]; then
            val=$(defaults read "${BUNDLE_ID}" "${key}" 2>/dev/null || true)
        fi

        if [[ "$val" == "1" || "$val" == "true" ]]; then
            printf "    %-28s : ${GREEN}%s${NC}\n" "$key" "ENABLED (1)"
        elif [[ "$val" == "0" || "$val" == "false" ]]; then
            printf "    %-28s : ${RED}%s${NC}\n" "$key" "DISABLED (0)"
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
    echo -e "  3. Verify policies at ${BOLD}brave://policy${NC}."
    echo ""
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

case "${1:-}" in
    --help|-h|help)
        print_banner
        echo "Usage: ./SlimBrave.sh [OPTION]"
        echo ""
        echo "Options:"
        echo "  -f, --full         Apply Full Debloat preset"
        echo "  -b, --balanced     Apply Balanced Privacy preset"
        echo "  -p, --performance  Apply Performance preset"
        echo "  -s, --status       Check currently active policies"
        echo "  -r, --revert       Remove all policies and restore defaults"
        echo "  -h, --help         Display this help message"
        echo ""
        echo "Tip: Run with or without sudo (User Mode vs System Managed Preferences)."
        exit 0
        ;;
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
    "")
        interactive_menu
        ;;
    *)
        echo -e "${RED}Unknown argument: $1${NC}"
        echo "Run '$0 --help' for available options."
        exit 1
        ;;
esac
