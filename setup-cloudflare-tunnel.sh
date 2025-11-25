#!/bin/bash

###############################################################################
# Cloudflare Tunnel Setup for Jellyfin
# Fast, free remote access without port forwarding
###############################################################################

set -euo pipefail

readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

readonly SETUP_DIR="${HOME}/jellyfin-server"
readonly CLOUDFLARED_DIR="${HOME}/.cloudflared"

echo "=========================================="
echo "  Cloudflare Tunnel Setup for Jellyfin"
echo "=========================================="
echo ""

# Check if Jellyfin is running (optional check)
if ! docker ps | grep -q jellyfin; then
    echo -e "${YELLOW}⚠${NC} Jellyfin is not currently running"
    echo "Note: You can start it later with: bash jellyfin-manage.sh start"
    echo ""
else
    echo -e "${GREEN}✓${NC} Jellyfin is running"
    echo ""
fi

# Install cloudflared
echo -e "${BLUE}Installing cloudflared...${NC}"
if ! command -v cloudflared &> /dev/null; then
    if command -v brew &> /dev/null; then
        brew install cloudflare/cloudflare/cloudflared
    else
        echo -e "${RED}✗${NC} Homebrew not found. Please install cloudflared manually:"
        echo "  Visit: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation/"
        exit 1
    fi
fi

echo -e "${GREEN}✓${NC} cloudflared installed"
echo ""

# Login to Cloudflare
echo -e "${BLUE}Step 1: Login to Cloudflare${NC}"
echo "This will open your browser. Please login with your Cloudflare account."
echo "(If you don't have one, create a free account at cloudflare.com)"
echo ""
read -p "Press Enter to continue..."

cloudflared tunnel login

if [[ ! -f "${CLOUDFLARED_DIR}/cert.pem" ]]; then
    echo -e "${RED}✗${NC} Login failed. Please try again."
    exit 1
fi

echo -e "${GREEN}✓${NC} Logged in to Cloudflare"
echo ""

# Create tunnel
echo -e "${BLUE}Step 2: Creating tunnel${NC}"
TUNNEL_NAME="jellyfin-$(hostname | tr '[:upper:]' '[:lower:]')"

# Check if tunnel already exists
if cloudflared tunnel list | grep -q "${TUNNEL_NAME}"; then
    echo -e "${YELLOW}⚠${NC} Tunnel already exists. Using existing tunnel."
else
    cloudflared tunnel create "${TUNNEL_NAME}"
fi

TUNNEL_ID=$(cloudflared tunnel list | grep "${TUNNEL_NAME}" | awk '{print $1}')
echo -e "${GREEN}✓${NC} Tunnel ID: ${TUNNEL_ID}"
echo ""

# Get subdomain
echo -e "${BLUE}Step 3: Configure subdomain${NC}"
echo "Choose a subdomain for your Jellyfin server."
echo "Example: jellyfin.yourdomain.com"
echo ""
read -p "Enter your domain (e.g., yourdomain.com): " DOMAIN
read -p "Enter subdomain (e.g., jellyfin): " SUBDOMAIN

FULL_DOMAIN="${SUBDOMAIN}.${DOMAIN}"

# Create config file
echo -e "${BLUE}Step 4: Creating configuration${NC}"

mkdir -p "${CLOUDFLARED_DIR}"

cat > "${CLOUDFLARED_DIR}/config.yml" <<EOF
tunnel: ${TUNNEL_ID}
credentials-file: ${CLOUDFLARED_DIR}/${TUNNEL_ID}.json

ingress:
  - hostname: ${FULL_DOMAIN}
    service: http://localhost:8096
    originRequest:
      noTLSVerify: true
  - service: http_status:404
EOF

echo -e "${GREEN}✓${NC} Configuration created"
echo ""

# Create DNS record
echo -e "${BLUE}Step 5: Creating DNS record${NC}"
cloudflared tunnel route dns "${TUNNEL_NAME}" "${FULL_DOMAIN}"
echo -e "${GREEN}✓${NC} DNS record created"
echo ""

# Create systemd/launchd service for auto-start
echo -e "${BLUE}Step 6: Setting up auto-start${NC}"

# Create launchd plist for macOS
PLIST_PATH="${HOME}/Library/LaunchAgents/com.cloudflare.cloudflared.plist"

cat > "${PLIST_PATH}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.cloudflare.cloudflared</string>
    <key>ProgramArguments</key>
    <array>
        <string>$(which cloudflared)</string>
        <string>tunnel</string>
        <string>--config</string>
        <string>${CLOUDFLARED_DIR}/config.yml</string>
        <string>run</string>
        <string>${TUNNEL_NAME}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>${CLOUDFLARED_DIR}/cloudflared.log</string>
    <key>StandardOutPath</key>
    <string>${CLOUDFLARED_DIR}/cloudflared.log</string>
</dict>
</plist>
EOF

launchctl load "${PLIST_PATH}" 2>/dev/null || true
launchctl start com.cloudflare.cloudflared

echo -e "${GREEN}✓${NC} Auto-start configured"
echo ""

# Test tunnel
echo -e "${BLUE}Step 7: Testing tunnel${NC}"
sleep 5

if curl -sf "https://${FULL_DOMAIN}" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Tunnel is working!"
else
    echo -e "${YELLOW}⚠${NC} Tunnel may take a minute to fully start"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}${BOLD}Setup Complete!${NC}"
echo "=========================================="
echo ""
echo -e "${BOLD}Your Jellyfin server is now accessible at:${NC}"
echo ""
echo -e "  🌐 https://${FULL_DOMAIN}"
echo ""
echo -e "${BOLD}Share this URL with your family!${NC}"
echo ""
echo "Notes:"
echo "  - HTTPS is automatically enabled"
echo "  - No port forwarding needed"
echo "  - Fast CDN delivery via Cloudflare"
echo "  - Tunnel will auto-start on boot"
echo ""
echo "Management:"
echo "  Start:  launchctl start com.cloudflare.cloudflared"
echo "  Stop:   launchctl stop com.cloudflare.cloudflared"
echo "  Logs:   tail -f ${CLOUDFLARED_DIR}/cloudflared.log"
echo ""
echo "=========================================="
