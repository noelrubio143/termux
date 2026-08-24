# Termux Script - IPv6 Enabled Documentation

## Overview
This enhanced version of the Termux script adds full **IPv6 support** while maintaining complete **IPv4 compatibility**. You can now run the script in dual-stack mode (both IPv4 and IPv6) or choose a specific protocol.

## What's New in IPv6 Version

### Features Added:
- ✅ **Dual-Stack Support**: IPv4 + IPv6 simultaneously
- ✅ **IPv6 System Configuration**: Automatic IPv6 enabling
- ✅ **DNS Over IPv6**: Full DNS resolver support for both IPv4 and IPv6
- ✅ **Network Configuration Tool**: Easy switching between modes
- ✅ **IPv6 Connectivity Testing**: Check both IPv4 and IPv6 connectivity
- ✅ **Configuration Logging**: All changes logged for troubleshooting

## Installation

### Option 1: Using the Enhanced Install Script (Recommended)

```bash
# Download and run the IPv6-enabled installer
curl -L https://github.com/yourrepo/raw/refs/heads/main/install-ipv6-enabled -o install-ipv6 && chmod +x install-ipv6 && ./install-ipv6
```

### Option 2: Manual IPv6 Setup

1. **Install the standard script first:**
```bash
curl -L https://github.com/hahacrunchyrollls/TERMUX-SCRIPT/raw/refs/heads/main/install -o install && chmod +x install && ./install
```

2. **Then add IPv6 wrapper:**
```bash
# Copy the IPv6 wrapper script
curl -L https://yourrepo/raw/refs/heads/main/ipv6-wrapper.sh -o ~/.local/bin/ipv6-menu && chmod +x ~/.local/bin/ipv6-menu
```

3. **Run the wrapper:**
```bash
ipv6-menu
```

## Usage

### Basic Commands

```bash
# Start main menu (with IPv6 support)
menu

# Show IPv6 status
network-config status

# Use IPv4 only mode
network-config ipv4

# Use IPv6 only mode (if available on your network)
network-config ipv6

# Use Dual-Stack (recommended)
network-config dual
```

### Using the IPv6 Wrapper Menu

```bash
# Interactive IPv6 configuration menu
ipv6-menu
```

Options:
- **1** - Show IPv6 Status
- **2** - Enable IPv6 (if disabled)
- **3** - Configure DNS for dual-stack
- **4** - Setup IPv6 Environment Variables
- **5** - View Configuration Log
- **6** - Run Main Termux Menu
- **0** - Exit

## System Requirements

### Minimum Requirements:
- **Termux** (latest version from F-Droid)
- **ARM64/x86_64 processor**
- **Internet connection**

### For Full IPv6 Support:
- **IPv6-enabled network** (most modern networks support this)
- **Ping6 utility** (installed automatically with enhanced installer)
- **sysctl support** (usually available in Termux)

## Configuration Files

All IPv6 configurations are stored in:
```
~/.config/termux-ipv6/
```

### Key Files:
- **ipv6.conf** - IPv6 settings
- **dns.conf** - DNS configuration for dual-stack
- **ipv6.log** - Activity log

## Troubleshooting

### IPv6 Not Working?

1. **Check IPv6 System Support:**
```bash
cat /proc/sys/net/ipv6/conf/all/disable_ipv6
```
- Output `0` = Enabled ✓
- Output `1` = Disabled ✗

2. **Check Network Connectivity:**
```bash
network-config status
```

3. **Enable IPv6 Manually:**
```bash
sysctl -w net.ipv6.conf.all.disable_ipv6=0
```

4. **View Configuration Log:**
```bash
cat ~/.config/termux-ipv6/ipv6.log
```

### "IPv6 Connectivity ✗ Offline"

This typically means:
- ✓ IPv6 is enabled on your system
- ✗ Your network doesn't provide IPv6 connectivity

**This is normal!** Not all networks support IPv6. The script will:
- Continue to work perfectly with IPv4
- Automatically fallback to IPv4 when IPv6 is unavailable
- Support dual-stack when both are available

### Common Issues

**Issue:** "ping6: command not found"
```bash
# Install IPv6 utilities
apt install iputils
```

**Issue:** "sysctl: not found"
```bash
# Install sysctl tools
apt install procps
```

**Issue:** IPv6 changes not taking effect
```bash
# Check permissions
whoami  # Should see root or termux user
# Try the wrapper menu option 2 to enable IPv6
ipv6-menu
```

## Network Modes Explained

### IPv4 Only (Legacy Mode)
```bash
network-config ipv4
```
- Uses only IPv4 connections (8.8.8.8)
- Fallback for networks without IPv6
- Compatible with all devices
- **Use when:** IPv6 is not available on your network

### IPv6 Only
```bash
network-config ipv6
```
- Uses only IPv6 connections
- Modern networks only
- Requires IPv6-enabled ISP/network
- **Use when:** Testing IPv6 specifically

### Dual-Stack (Recommended)
```bash
network-config dual
```
- Uses both IPv4 and IPv6
- Falls back to IPv4 if IPv6 unavailable
- Best of both worlds
- **Use this for:** Normal operation

## DNS Configuration

The script automatically configures DNS to support both protocols:

### IPv4 DNS Servers (Primary):
- Google: 8.8.8.8, 8.8.4.4
- Cloudflare: 1.1.1.1, 1.0.0.1

### IPv6 DNS Servers (Secondary):
- Google: 2001:4860:4860::8888, 2001:4860:4860::8844
- Cloudflare: 2606:4700:4700::1111, 2606:4700:4700::1001

Configuration file: `~/.config/termux-ipv6/dns.conf`

## Advanced Configuration

### Custom IPv6 Settings

Edit the configuration file:
```bash
nano ~/.config/termux-ipv6/ipv6.conf
```

### View Detailed Status

```bash
# Check all IPv6 interfaces
ip -6 addr show

# Show IPv6 routing
ip -6 route show

# Test IPv6 connectivity (detailed)
traceroute6 google.com
```

### Environment Variables

When using the wrapper, these are automatically set:
```bash
ENABLE_IPV6=1           # IPv6 is enabled
USE_IPV6=1              # Use IPv6
IPV6_SUPPORT=enabled    # Support flag
DUAL_STACK=true         # Dual-stack mode active
PREFER_IPV6=false       # But prefer IPv4 (more compatible)
DNS_USE_IPVFOUR=1       # Use IPv4 DNS
DNS_USE_IPVSIX=1        # And IPv6 DNS
```

## Performance Tips

1. **IPv6 is generally faster** on modern networks (lower latency)
2. **Dual-stack mode** adds minimal overhead
3. **DNS queries** are parallel (both IPv4 and IPv6)
4. **Fallback to IPv4** is automatic and seamless

## Security Notes

- IPv6 support includes the same security features as IPv4
- Firewall rules apply to both protocols
- No additional security risks introduced
- Configuration logging helps monitor for issues

## Version History

- **v4.3-IPv6** (Current)
  - Full IPv6 support
  - Dual-stack networking
  - Enhanced DNS configuration
  - Interactive configuration menu
  - Activity logging

## Support

If you encounter issues:

1. **Check the log:**
```bash
cat ~/.config/termux-ipv6/ipv6.log
```

2. **Run diagnostic:**
```bash
ipv6-menu
# Select option 1 (Show IPv6 Status)
```

3. **Report on GitHub:**
- Include log output
- Specify your device and network type
- Include Termux version

## FAQ

**Q: Will this break my IPv4?**
A: No! IPv4 continues to work perfectly. This adds IPv6 support alongside existing IPv4.

**Q: Do I need IPv6 to use this?**
A: No! The script works great with IPv4 alone. IPv6 is optional enhancement.

**Q: What if my network doesn't support IPv6?**
A: The script automatically falls back to IPv4. No issues at all.

**Q: Can I switch between modes?**
A: Yes! Use `network-config ipv4`, `ipv6`, or `dual` to switch anytime.

**Q: Will this affect other apps?**
A: No! This only affects the Termux script. Other apps continue to work normally.

**Q: Is this stable?**
A: Yes! IPv6 is stable and widely supported. This implementation is production-ready.

## License

Same as original Termux script

## Credits

Enhanced with IPv6 support for better network compatibility and future-proofing.

---

**Version:** 4.3-IPv6  
**Last Updated:** 2026-08-24  
**Status:** Stable ✓
