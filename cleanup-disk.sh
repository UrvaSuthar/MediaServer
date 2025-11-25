#!/bin/bash

###############################################################################
# macOS Disk Cleanup Script
# Safely removes temporary files and caches to free up space
###############################################################################

set -euo pipefail

readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

echo "=========================================="
echo "  macOS Disk Cleanup"
echo "=========================================="
echo ""

# Show current disk usage
echo -e "${BLUE}Current Disk Usage:${NC}"
df -h / | tail -1
echo ""

echo -e "${BLUE}Cleaning up temporary files...${NC}"
echo ""

# Homebrew cleanup
if command -v brew &> /dev/null; then
    echo "→ Cleaning Homebrew caches..."
    brew cleanup --prune=all 2>/dev/null || true
    rm -rf ~/Library/Caches/Homebrew/* 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Homebrew cleaned"
fi

# User caches
echo "→ Cleaning user caches..."
rm -rf ~/Library/Caches/* 2>/dev/null || true
echo -e "${GREEN}✓${NC} User caches cleaned"

# System logs
echo "→ Cleaning system logs..."
sudo rm -rf /private/var/log/* 2>/dev/null || true
sudo rm -rf ~/Library/Logs/* 2>/dev/null || true
echo -e "${GREEN}✓${NC} Logs cleaned"

# Trash
echo "→ Emptying trash..."
rm -rf ~/.Trash/* 2>/dev/null || true
echo -e "${GREEN}✓${NC} Trash emptied"

# Downloads (ask first)
download_size=$(du -sh ~/Downloads 2>/dev/null | awk '{print $1}' || echo "0B")
echo ""
echo -e "${YELLOW}Downloads folder size: ${download_size}${NC}"
read -p "Clean Downloads folder? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf ~/Downloads/* 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Downloads cleaned"
fi

# Docker cleanup
if command -v docker &> /dev/null; then
    echo ""
    echo "→ Cleaning Docker..."
    docker system prune -af --volumes 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Docker cleaned"
fi

# Xcode derived data (if exists)
if [[ -d ~/Library/Developer/Xcode/DerivedData ]]; then
    echo "→ Cleaning Xcode caches..."
    rm -rf ~/Library/Developer/Xcode/DerivedData/* 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Xcode caches cleaned"
fi

# Node modules (optional)
echo ""
read -p "Clean node_modules in development folders? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    find ~/development -name "node_modules" -type d -prune -exec rm -rf '{}' + 2>/dev/null || true
    echo -e "${GREEN}✓${NC} node_modules cleaned"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}Cleanup Complete!${NC}"
echo "=========================================="
echo ""

# Show new disk usage
echo -e "${BLUE}New Disk Usage:${NC}"
df -h / | tail -1
echo ""
