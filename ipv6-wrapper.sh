#!/bin/bash
# IPv6 Wrapper for Termux Script
# This script enables IPv6 support before running the main Termux binary

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Configuration
CONFIG_DIR="${HOME}/.config/termux-ipv6"
CONFIG_FILE="${CONFIG_DIR}/ipv6.conf"
LOG_FILE="${CONFIG_DIR}/ipv6.log"

# Create config directory
mkdir -p "${CONFIG_DIR}"

# Function to log
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "${LOG_FILE}"
    echo -e "$2"
}

# Function to check IPv6 support
check_ipv6_support() {
    log_message "Checking IPv6 support..." "${CYAN}[*] Checking IPv6 support...${NC}"
    
    # Check if IPv6 module is loaded
    if lsmod 2>/dev/null | grep -q ipv6; then
        log_message "IPv6 module loaded" "${GREEN}✓ IPv6 module is loaded${NC}"
        return 0
    elif [ -f /proc/sys/net/ipv6/conf/all/disable_ipv6 ]; then
        disable_status=$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6)
        if [ "$disable_status" == "0" ]; then
            log_message "IPv6 is enabled" "${GREEN}✓ IPv6 is enabled${NC}"
            return 0
        else
            log_message "IPv6 is disabled" "${YELLOW}⚠ IPv6 is disabled in system${NC}"
            return 1
        fi
    else
        log_message "IPv6 status unknown" "${YELLOW}⚠ Could not determine IPv6 status${NC}"
        return 2
    fi
}

# Function to enable IPv6
enable_ipv6_support() {
    log_message "Attempting to enable IPv6..." "${CYAN}[*] Enabling IPv6 support...${NC}"
    
    # Try using sysctl if available
    if command -v sysctl &> /dev/null; then
        sysctl -w net.ipv6.conf.all.disable_ipv6=0 2>/dev/null && \
        log_message "IPv6 enabled via sysctl" "${GREEN}✓ IPv6 enabled${NC}" || \
        log_message "sysctl IPv6 enable failed" "${YELLOW}⚠ Could not enable via sysctl${NC}"
    fi
    
    # Try direct /proc modification if available
    if [ -w /proc/sys/net/ipv6/conf/all/disable_ipv6 ]; then
        echo 0 > /proc/sys/net/ipv6/conf/all/disable_ipv6 2>/dev/null && \
        log_message "IPv6 enabled via /proc" "${GREEN}✓ IPv6 enabled via /proc${NC}" || \
        log_message "/proc IPv6 enable failed" "${YELLOW}⚠ Could not enable via /proc${NC}"
    fi
}

# Function to setup environment variables for IPv6
setup_ipv6_env() {
    log_message "Setting up IPv6 environment variables..." "${CYAN}[*] Setting up IPv6 environment...${NC}"
    
    # Export IPv6-related environment variables
    export ENABLE_IPV6=1
    export USE_IPV6=1
    export IPV6_SUPPORT=enabled
    export DUAL_STACK=true
    export PREFER_IPV6=false  # Prefer IPv4 but support IPv6
    
    # DNS settings for IPv6
    export DNS_USE_IPVFOUR=1  # Keep IPv4 DNS as primary
    export DNS_USE_IPVSIX=1   # But also enable IPv6 DNS queries
    
    log_message "Environment variables set" "${GREEN}✓ IPv6 environment configured${NC}"
}

# Function to configure DNS for both IPv4 and IPv6
configure_dns() {
    log_message "Configuring DNS for dual-stack..." "${CYAN}[*] Configuring DNS settings...${NC}"
    
    # Create DNS configuration file
    cat > "${CONFIG_DIR}/dns.conf" << 'EOF'
# DNS Configuration for Dual-Stack (IPv4 + IPv6)
# IPv4 DNS servers
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
nameserver 1.0.0.1

# IPv6 DNS servers
nameserver 2001:4860:4860::8888
nameserver 2001:4860:4860::8844
nameserver 2606:4700:4700::1111
nameserver 2606:4700:4700::1001
EOF
    
    log_message "DNS configuration created" "${GREEN}✓ DNS configured for dual-stack${NC}"
}

# Function to display IPv6 status
show_ipv6_status() {
    clear
    echo -e "${WHITE}╔════════════════════════════════════╗${NC}"
    echo -e "${WHITE}   IPv6 Configuration Status          ${NC}"
    echo -e "${WHITE}╚════════════════════════════════════╝${NC}"
    echo
    
    log_message "Displaying IPv6 status" "${CYAN}[*] IPv6 Status:${NC}"
    
    # Check IPv4
    echo -e "${CYAN}IPv4 Support:${NC}"
    if ping -c 1 8.8.8.8 &>/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} IPv4 connectivity available"
        log_message "IPv4 test passed" ""
    else
        echo -e "  ${RED}✗${NC} IPv4 connectivity not available"
        log_message "IPv4 test failed" ""
    fi
    
    # Check IPv6
    echo -e "${CYAN}IPv6 Support:${NC}"
    if command -v ping6 &>/dev/null; then
        if ping6 -c 1 2001:4860:4860::8888 &>/dev/null 2>&1; then
            echo -e "  ${GREEN}✓${NC} IPv6 connectivity available"
            log_message "IPv6 connectivity test passed" ""
        else
            echo -e "  ${YELLOW}⚠${NC} IPv6 not available on network"
            log_message "IPv6 network connectivity not available" ""
        fi
    else
        echo -e "  ${YELLOW}⚠${NC} ping6 not available (install iputils for full support)"
    fi
    
    # Check IPv6 system support
    if [ -f /proc/sys/net/ipv6/conf/all/disable_ipv6 ]; then
        disable_status=$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6)
        if [ "$disable_status" == "0" ]; then
            echo -e "  ${GREEN}✓${NC} IPv6 system support: Enabled"
            log_message "IPv6 system support enabled" ""
        else
            echo -e "  ${RED}✗${NC} IPv6 system support: Disabled"
            log_message "IPv6 system support disabled" ""
        fi
    fi
    
    echo
    echo -e "${CYAN}Configuration:${NC}"
    echo -e "  Config Directory: ${CONFIG_DIR}"
    echo -e "  Log File: ${LOG_FILE}"
    echo -e "  Dual-Stack Mode: ${GREEN}ACTIVE${NC}"
    echo
    
    # Show recent log entries
    if [ -f "${LOG_FILE}" ]; then
        echo -e "${CYAN}Recent Activity:${NC}"
        tail -5 "${LOG_FILE}" | sed 's/^/  /'
    fi
    
    echo
}

# Function to display menu
show_menu() {
    while true; do
        clear
        echo -e "${WHITE}╔════════════════════════════════════╗${NC}"
        echo -e "${WHITE}   Termux IPv6 Configuration Menu     ${NC}"
        echo -e "${WHITE}╚════════════════════════════════════╝${NC}"
        echo
        echo -e "${CYAN}Options:${NC}"
        echo -e "  ${GREEN}1${NC} - Show IPv6 Status"
        echo -e "  ${GREEN}2${NC} - Enable IPv6"
        echo -e "  ${GREEN}3${NC} - Configure DNS"
        echo -e "  ${GREEN}4${NC} - Setup IPv6 Environment"
        echo -e "  ${GREEN}5${NC} - View Configuration Log"
        echo -e "  ${GREEN}6${NC} - Run Main Termux Menu"
        echo -e "  ${GREEN}0${NC} - Exit"
        echo
        read -p "Choose option: " choice
        
        case $choice in
            1) show_ipv6_status; read -p "Press Enter to continue..."; ;;
            2) enable_ipv6_support; read -p "Press Enter to continue..."; ;;
            3) configure_dns; read -p "Press Enter to continue..."; ;;
            4) setup_ipv6_env; read -p "Press Enter to continue..."; ;;
            5) clear; cat "${LOG_FILE}" 2>/dev/null | tail -20 || echo "No log available yet"; read -p "Press Enter to continue..."; ;;
            6) 
                log_message "Launching main Termux menu" "${CYAN}[*] Starting main menu...${NC}"
                if command -v menu &>/dev/null; then
                    exec menu
                else
                    echo -e "${RED}✗ Main menu not found${NC}"
                    read -p "Press Enter to continue..."
                fi
                ;;
            0) log_message "IPv6 wrapper exited" ""; echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid option${NC}"; read -p "Press Enter to continue..."; ;;
        esac
    done
}

# Main execution
main() {
    log_message "IPv6 wrapper started" "${CYAN}[*] Termux IPv6 Wrapper v1.0${NC}"
    
    # Check and enable IPv6
    check_ipv6_support || enable_ipv6_support
    
    # Setup environment
    setup_ipv6_env
    
    # Configure DNS
    configure_dns
    
    log_message "IPv6 wrapper initialization complete" "${GREEN}✓ Initialization complete${NC}"
    
    # Show interactive menu
    show_menu
}

# Run main function
main
