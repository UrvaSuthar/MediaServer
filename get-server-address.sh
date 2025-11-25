#!/bin/bash

# Quick script to get all Jellyfin server addresses

echo "🎬 Jellyfin Server Addresses"
echo "=========================================="
echo ""

# Check if Jellyfin is running
if ! docker ps | grep -q jellyfin; then
    echo "⚠️  Jellyfin is not running!"
    echo "Start it with: docker compose up -d"
    exit 1
fi

echo "✅ Jellyfin is running"
echo ""

# Local address
echo "📍 Local Access:"
echo "   http://localhost:8096"
echo ""

# Network address
WIFI_IP=$(ipconfig getifaddr en0 2>/dev/null || echo "")
if [ -n "$WIFI_IP" ]; then
    echo "📱 Same WiFi Network:"
    echo "   http://$WIFI_IP:8096"
    echo ""
    
    # Generate QR code for mobile (if qrencode is installed)
    if command -v qrencode &> /dev/null; then
        echo "📲 Scan this QR code on your phone:"
        qrencode -t ANSI "http://$WIFI_IP:8096"
        echo ""
    fi
fi

# Ethernet address
ETH_IP=$(ipconfig getifaddr en1 2>/dev/null || echo "")
if [ -n "$ETH_IP" ]; then
    echo "🔌 Ethernet Network:"
    echo "   http://$ETH_IP:8096"
    echo ""
fi

# Tailscale address
if command -v tailscale &> /dev/null; then
    TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "")
    if [ -n "$TAILSCALE_IP" ]; then
        echo "🌐 Remote Access (Tailscale):"
        echo "   http://$TAILSCALE_IP:8096"
        echo ""
    else
        echo "💡 Tip: Run 'tailscale up' for remote access"
        echo ""
    fi
fi

echo "=========================================="
