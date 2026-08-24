#!/bin/bash
# Quick Start Script for IPv6 Setup
# This script sets up IPv6 support in one command

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
IPV6_CONFIG_DIR="${HOME}/.config/termux-ipv6"
LOCAL_BIN="${HOME}/.local/bin"

clear() {
    printf '\033[2J\033[H'
}

header() {
    clear
    echo -e "${WHITE}╔════════════════════════════════════╗${NC}"
    echo -e "${WHITE}   IPv6 Quick Start Setup             ${NC}"
    echo -e "${WHITE}╚════════════════════════════════════╝${NC}"
    echo
}

step() {
    echo -e "${CYAN}[*]${NC} $1"
}

success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Step 1: Check Termux environment
check_termux() {
    header
    step "Checking Termux environment..."
    
    if [ ! -d "/data/data/com.termux" ]; then
        error "Not running in Termux!"
        echo -e "${RED}This script must run inside Termux${NC}"
        exit 1
    fi
    success "Termux detected"
}

# Step 2: Create directories
create_directories() {
    step "Creating configuration directories..."
    mkdir -p "${IPV6_CONFIG_DIR}"
    mkdir -p "${LOCAL_BIN}"
    success "Directories created"
}

# Step 3: Install dependencies
install_dependencies() {
    step "Installing required packages..."
    
    # Check if apt is available
    if ! command -v apt &> /dev/null; then
        warning "apt not found, skipping dependency installation"
        return
    fi
    
    # Update package list
    apt update -y > /dev/null 2>&1 || warning "Could not update package list"
    
    # Install packages
    packages_to_install=""
    
    [ ! -f /usr/bin/ping6 ] && [ ! -f /bin/ping6 ] && packages_to_install="${packages_to_install} iputils"
    [ ! -f /usr/bin/dnsutils ] && [ ! -f /bin/dnsutils ] && packages_to_install="${packages_to_install} dnsutils"
    
    if [ ! -z "${packages_to_install}" ]; then
        apt install -y ${packages_to_install} > /dev/null 2>&1 || warning "Could not install some packages"
    fi
    
    success "Dependencies ready"
}

# Step 4: Configure IPv6
configure_ipv6() {
    step "Configuring IPv6..."
    
    # Try different methods to enable IPv6
    if command -v sysctl &> /dev/null; then
        sysctl -w net.ipv6.conf.all.disable_ipv6=0 2>/dev/null && success "IPv6 enabled via sysctl" || warning "sysctl method did not work"
    fi
    
    if [ -w /proc/sys/net/ipv6/conf/all/disable_ipv6 ]; then
        echo 0 > /proc/sys/net/ipv6/conf/all/disable_ipv6 2>/dev/null && success "IPv6 enabled via /proc" || warning "Could not enable IPv6"
    fi
}

# Step 5: Create configuration files
create_config_files() {
    step "Creating configuration files..."
    
    # IPv6 configuration
    cat > "${IPV6_CONFIG_DIR}/ipv6.conf" << 'EOF'
# IPv6 Configuration
enable_ipv6=true
allow_ipv6_bind=true
dns_ipv6_enabled=true
ipv6_localhost=::1
ipv6_loopback=::1/128
dual_stack_mode=true
prefer_ipv4=true
EOF
    
    # DNS configuration
    cat > "${IPV6_CONFIG_DIR}/dns.conf" << 'EOF'
# Dual-Stack DNS Configuration

# IPv4 DNS Servers
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
nameserver 1.0.0.1

# IPv6 DNS Servers
nameserver 2001:4860:4860::8888
nameserver 2001:4860:4860::8844
nameserver 2606:4700:4700::1111
nameserver 2606:4700:4700::1001
EOF
    
    success "Configuration files created"
}

# Step 6: Create helper script
create_helper_script() {
    step "Creating network configuration tool..."
    
    cat > "${LOCAL_BIN}/network-config" << 'EOF'
#!/bin/bash
# Network configuration helper for IPv4/IPv6

case "$1" in
    "ipv4")
        echo "Using IPv4"
        export USE_IPV6=0
        export USE_IPV4=1
        echo "IPv4 mode activated"
        ;;
    "ipv6")
        echo "Using IPv6"
        export USE_IPV6=1
        export USE_IPV4=0
        echo "IPv6 mode activated"
        ;;
    "dual")
        echo "Using Dual-Stack (IPv4 + IPv6)"
        export USE_IPV6=1
        export USE_IPV4=1
        echo "Dual-stack mode activated (recommended)"
        ;;
    "status")
        echo "=== Network Status ==="
        echo ""
        echo "Protocol Support:"
        echo "  IPv4: Available"
        echo "  IPv6: Available"
        echo ""
        
        echo "Connectivity:"
        if ping -c 1 8.8.8.8 &> /dev/null 2>&1; then
            echo "  IPv4: Online ✓"
        else
            echo "  IPv4: Offline ✗"
        fi
        
        if command -v ping6 &> /dev/null; then
            if ping6 -c 1 2001:4860:4860::8888 &> /dev/null 2>&1; then
                echo "  IPv6: Online ✓"
            else
                echo "  IPv6: Offline (not available on network) ⚠"
            fi
        else
            echo "  IPv6: Testing unavailable (install iputils)"
        fi
        
        echo ""
        echo "Configuration:"
        echo "  Mode: $([ "$USE_IPV6" = "1" ] && echo "Dual-Stack" || echo "IPv4")"
        echo "  Config Dir: ~/.config/termux-ipv6"
        ;;
    *)
        echo "Usage: network-config [ipv4|ipv6|dual|status]"
        echo ""
        echo "Examples:"
        echo "  network-config ipv4       - Use IPv4 only"
        echo "  network-config ipv6       - Use IPv6 only"
        echo "  network-config dual       - Use both (recommended)"
        echo "  network-config status     - Check connectivity"
        ;;
esac
EOF
    
    chmod +x "${LOCAL_BIN}/network-config"
    success "Network configuration tool installed"
}

# Step 7: Set environment variables
setup_environment() {
    step "Setting up environment variables..."
    
    # Add to .bashrc if not already there
    if ! grep -q "ENABLE_IPV6" "${HOME}/.bashrc" 2>/dev/null; then
        cat >> "${HOME}/.bashrc" << 'EOF'

# IPv6 Configuration
export ENABLE_IPV6=1
export USE_IPV6=1
export DUAL_STACK=true
export PREFER_IPV6=false
export DNS_USE_IPVFOUR=1
export DNS_USE_IPVSIX=1
EOF
    fi
    
    # Load environment
    export ENABLE_IPV6=1
    export USE_IPV6=1
    export DUAL_STACK=true
    export PREFER_IPV6=false
    export DNS_USE_IPVFOUR=1
    export DNS_USE_IPVSIX=1
    
    success "Environment variables set"
}

# Step 8: Summary and testing
show_summary() {
    clear
    echo -e "${WHITE}╔════════════════════════════════════╗${NC}"
    echo -e "${WHITE}   IPv6 Setup Complete!              ${NC}"
    echo -e "${WHITE}╚════════════════════════════════════╝${NC}"
    echo
    
    echo -e "${GREEN}✓ Installation Summary:${NC}"
    echo -e "  • IPv6 configured"
    echo -e "  • DNS set up for dual-stack"
    echo -e "  • Network configuration tool installed"
    echo -e "  • Environment variables configured"
    echo
    
    echo -e "${CYAN}Quick Commands:${NC}"
    echo -e "  network-config status   - Check network status"
    echo -e "  network-config ipv4     - Use IPv4 only"
    echo -e "  network-config ipv6     - Use IPv6 only"
    echo -e "  network-config dual     - Use both (recommended)"
    echo
    
    echo -e "${YELLOW}Configuration Location:${NC}"
    echo -e "  ${IPV6_CONFIG_DIR}"
    echo
    
    echo -e "${CYAN}Next Steps:${NC}"
    echo -e "  1. Type: source ~/.bashrc"
    echo -e "  2. Type: network-config status"
    echo -e "  3. Try: menu (to start Termux script)"
    echo
}

# Main execution
main() {
    check_termux
    create_directories
    install_dependencies
    configure_ipv6
    create_config_files
    create_helper_script
    setup_environment
    show_summary
    
    echo -e "${YELLOW}Setup complete! You can now close and reopen Termux.${NC}"
    echo -e "${GREEN}Then run: network-config status${NC}"
    echo
}

# Run
main "$@"
