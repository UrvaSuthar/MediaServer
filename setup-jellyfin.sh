#!/bin/bash

# Jellyfin Media Server - One-Command Setup Script
# Usage: bash setup-jellyfin.sh

set -e  # Exit on error

echo "🎬 Jellyfin Media Server - Automated Setup"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Docker is installed
echo "📦 Checking prerequisites..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker Desktop first."
    echo "   Download from: https://www.docker.com/products/docker-desktop"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "❌ Docker is not running. Please start Docker Desktop."
    exit 1
fi

echo -e "${GREEN}✓${NC} Docker is installed and running"

# Get username
CURRENT_USER=$(whoami)
echo -e "${GREEN}✓${NC} Current user: $CURRENT_USER"

# Create directory structure
echo ""
echo "📁 Creating directory structure..."

BASE_DIR="$HOME/Media"
CONFIG_DIR="$HOME/jellyfin-config"

mkdir -p "$BASE_DIR"/{movies,tv-shows,music,photos}
mkdir -p "$CONFIG_DIR"/{config,cache,logs}

echo -e "${GREEN}✓${NC} Media directory: $BASE_DIR"
echo -e "${GREEN}✓${NC} Config directory: $CONFIG_DIR"

# Create docker-compose.yml
echo ""
echo "🐳 Creating Docker Compose configuration..."

SETUP_DIR="$HOME/jellyfin-server"
mkdir -p "$SETUP_DIR"

cat > "$SETUP_DIR/docker-compose.yml" <<EOF
version: '3.8'

services:
  jellyfin:
    image: jellyfin/jellyfin:latest
    container_name: jellyfin
    restart: unless-stopped
    ports:
      - "8096:8096"    # HTTP Web UI
      - "8920:8920"    # HTTPS Web UI (optional)
      - "7359:7359/udp"  # Service discovery
      - "1900:1900/udp"  # DLNA discovery
    volumes:
      - $CONFIG_DIR/config:/config
      - $CONFIG_DIR/cache:/cache
      - $BASE_DIR:/media:ro
    environment:
      - TZ=Asia/Kolkata
      - JELLYFIN_PublishedServerUrl=http://localhost:8096
EOF

echo -e "${GREEN}✓${NC} Docker Compose file created: $SETUP_DIR/docker-compose.yml"

# Start Jellyfin
echo ""
echo "🚀 Starting Jellyfin server..."
cd "$SETUP_DIR"
docker compose up -d

echo ""
echo "⏳ Waiting for Jellyfin to start (15 seconds)..."
sleep 15

# Get server addresses
echo ""
echo "=========================================="
echo -e "${GREEN}✅ Jellyfin Server is Running!${NC}"
echo "=========================================="
echo ""

# Local address
echo -e "${BLUE}📍 Local Access (this computer):${NC}"
echo "   http://localhost:8096"
echo ""

# Network address
WIFI_IP=$(ipconfig getifaddr en0 2>/dev/null || echo "Not connected")
if [ "$WIFI_IP" != "Not connected" ]; then
    echo -e "${BLUE}📱 Network Access (same WiFi):${NC}"
    echo "   http://$WIFI_IP:8096"
    echo ""
fi

# Tailscale address (if available)
if command -v tailscale &> /dev/null; then
    TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "")
    if [ -n "$TAILSCALE_IP" ]; then
        echo -e "${BLUE}🌐 Remote Access (Tailscale VPN):${NC}"
        echo "   http://$TAILSCALE_IP:8096"
        echo ""
    fi
fi

echo "=========================================="
echo -e "${YELLOW}📝 Next Steps:${NC}"
echo ""
echo "1. Open http://localhost:8096 in your browser"
echo "2. Complete the setup wizard:"
echo "   - Select language"
echo "   - Create admin account"
echo "   - Set up libraries (optional in wizard)"
echo ""
echo "3. Add media files to:"
echo "   - Movies: $BASE_DIR/movies/"
echo "   - TV Shows: $BASE_DIR/tv-shows/"
echo "   - Music: $BASE_DIR/music/"
echo "   - Photos: $BASE_DIR/photos/"
echo ""
echo "=========================================="
echo -e "${GREEN}📚 Useful Commands:${NC}"
echo ""
echo "  Start:   cd $SETUP_DIR && docker compose up -d"
echo "  Stop:    cd $SETUP_DIR && docker compose down"
echo "  Logs:    cd $SETUP_DIR && docker compose logs -f"
echo "  Status:  docker ps | grep jellyfin"
echo ""
echo "=========================================="
echo ""
echo -e "${GREEN}🎉 Setup Complete! Enjoy your media server!${NC}"
