#!/bin/bash

###############################################################################
# Jellyfin Management Script
# Comprehensive management tool for Jellyfin media server
###############################################################################

set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Configuration
readonly SETUP_DIR="${HOME}/jellyfin-server"
readonly CONFIG_DIR="${HOME}/jellyfin-config"
readonly BACKUP_DIR="${SETUP_DIR}/backups"

###############################################################################
# Helper functions
###############################################################################

check_setup() {
    if [[ ! -f "${SETUP_DIR}/docker-compose.yml" ]]; then
        echo -e "${RED}✗${NC} Jellyfin is not set up yet"
        echo "Run: bash setup-jellyfin.sh"
        exit 1
    fi
}

is_running() {
    docker ps | grep -q jellyfin
}

###############################################################################
# Management commands
###############################################################################

cmd_start() {
    echo -e "${BLUE}Starting Jellyfin...${NC}"
    cd "${SETUP_DIR}"
    docker compose up -d
    echo -e "${GREEN}✓${NC} Jellyfin started"
}

cmd_stop() {
    echo -e "${BLUE}Stopping Jellyfin...${NC}"
    cd "${SETUP_DIR}"
    docker compose down
    echo -e "${GREEN}✓${NC} Jellyfin stopped"
}

cmd_restart() {
    echo -e "${BLUE}Restarting Jellyfin...${NC}"
    cd "${SETUP_DIR}"
    docker compose restart
    echo -e "${GREEN}✓${NC} Jellyfin restarted"
}

cmd_status() {
    echo "=========================================="
    echo "  Jellyfin Server Status"
    echo "=========================================="
    echo ""
    
    if is_running; then
        echo -e "${GREEN}✓${NC} Status: Running"
        
        # Get container info
        docker ps --filter "name=jellyfin" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        echo ""
        
        # Get addresses
        echo "Access URLs:"
        echo "  Local: http://localhost:8096"
        
        local wifi_ip=$(ipconfig getifaddr en0 2>/dev/null || echo "")
        if [[ -n "${wifi_ip}" ]]; then
            echo "  Network: http://${wifi_ip}:8096"
        fi
        
        if command -v tailscale &> /dev/null; then
            local ts_ip=$(tailscale ip -4 2>/dev/null || echo "")
            if [[ -n "${ts_ip}" ]]; then
                echo "  Tailscale: http://${ts_ip}:8096"
            fi
        fi
    else
        echo -e "${RED}✗${NC} Status: Stopped"
    fi
    echo ""
}

cmd_logs() {
    local follow="${1:-}"
    cd "${SETUP_DIR}"
    
    if [[ "${follow}" == "-f" || "${follow}" == "--follow" ]]; then
        docker compose logs -f jellyfin
    else
        docker compose logs --tail=50 jellyfin
    fi
}

cmd_update() {
    echo -e "${BLUE}Updating Jellyfin...${NC}"
    
    # Create backup first
    cmd_backup
    
    # Pull latest image
    cd "${SETUP_DIR}"
    docker compose pull
    
    # Restart with new image
    docker compose up -d
    
    echo -e "${GREEN}✓${NC} Jellyfin updated to latest version"
}

cmd_backup() {
    mkdir -p "${BACKUP_DIR}"
    
    local backup_name="jellyfin-config-$(date +%Y%m%d_%H%M%S).tar.gz"
    local backup_path="${BACKUP_DIR}/${backup_name}"
    
    echo -e "${BLUE}Creating backup...${NC}"
    
    if [[ -d "${CONFIG_DIR}/config" ]]; then
        tar -czf "${backup_path}" -C "${CONFIG_DIR}" config
        echo -e "${GREEN}✓${NC} Backup created: ${backup_path}"
        
        # Keep only last 5 backups
        ls -t "${BACKUP_DIR}"/jellyfin-config-*.tar.gz 2>/dev/null | tail -n +6 | xargs -r rm
    else
        echo -e "${YELLOW}⚠${NC} No configuration to backup"
    fi
}

cmd_restore() {
    local backup_file="$1"
    
    if [[ ! -f "${backup_file}" ]]; then
        echo -e "${RED}✗${NC} Backup file not found: ${backup_file}"
        exit 1
    fi
    
    echo -e "${YELLOW}⚠${NC} This will overwrite your current configuration"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Stop server
        cmd_stop
        
        # Restore backup
        echo -e "${BLUE}Restoring backup...${NC}"
        tar -xzf "${backup_file}" -C "${CONFIG_DIR}"
        
        # Start server
        cmd_start
        
        echo -e "${GREEN}✓${NC} Backup restored"
    fi
}

cmd_clean() {
    echo -e "${BLUE}Cleaning up...${NC}"
    
    cd "${SETUP_DIR}"
    
    # Remove stopped containers
    docker compose down --remove-orphans
    
    # Clean cache
    if [[ -d "${CONFIG_DIR}/cache" ]]; then
        rm -rf "${CONFIG_DIR}/cache"/*
        echo -e "${GREEN}✓${NC} Cache cleaned"
    fi
    
    # Remove old images
    docker image prune -f
    
    echo -e "${GREEN}✓${NC} Cleanup complete"
}

cmd_addresses() {
    echo "=========================================="
    echo "  Jellyfin Server Addresses"
    echo "=========================================="
    echo ""
    
    if ! is_running; then
        echo -e "${RED}✗${NC} Jellyfin is not running"
        echo "Start it with: jellyfin-manage start"
        exit 1
    fi
    
    echo "📍 Local Access:"
    echo "   http://localhost:8096"
    echo ""
    
    local wifi_ip=$(ipconfig getifaddr en0 2>/dev/null || echo "")
    if [[ -n "${wifi_ip}" ]]; then
        echo "📱 Same WiFi Network:"
        echo "   http://${wifi_ip}:8096"
        echo ""
    fi
    
    if command -v tailscale &> /dev/null; then
        local ts_ip=$(tailscale ip -4 2>/dev/null || echo "")
        if [[ -n "${ts_ip}" ]]; then
            echo "🌐 Remote Access (Tailscale):"
            echo "   http://${ts_ip}:8096"
            echo ""
        fi
    fi
    
    echo "=========================================="
}

cmd_help() {
    cat << EOF
Jellyfin Management Tool

Usage: jellyfin-manage COMMAND [OPTIONS]

Commands:
    start           Start Jellyfin server
    stop            Stop Jellyfin server
    restart         Restart Jellyfin server
    status          Show server status and info
    logs [-f]       Show logs (use -f to follow)
    update          Update to latest version
    backup          Create configuration backup
    restore FILE    Restore from backup file
    clean           Clean cache and old data
    addresses       Show all server addresses
    help            Show this help message

Examples:
    jellyfin-manage start
    jellyfin-manage logs -f
    jellyfin-manage backup
    jellyfin-manage restore backups/jellyfin-config-20250126_001234.tar.gz

EOF
}

###############################################################################
# Main
###############################################################################

main() {
    check_setup
    
    local command="${1:-help}"
    
    case "${command}" in
        start)
            cmd_start
            ;;
        stop)
            cmd_stop
            ;;
        restart)
            cmd_restart
            ;;
        status)
            cmd_status
            ;;
        logs)
            cmd_logs "${2:-}"
            ;;
        update)
            cmd_update
            ;;
        backup)
            cmd_backup
            ;;
        restore)
            if [[ -z "${2:-}" ]]; then
                echo -e "${RED}✗${NC} Please specify backup file"
                exit 1
            fi
            cmd_restore "$2"
            ;;
        clean)
            cmd_clean
            ;;
        addresses)
            cmd_addresses
            ;;
        help|--help|-h)
            cmd_help
            ;;
        *)
            echo -e "${RED}✗${NC} Unknown command: ${command}"
            cmd_help
            exit 1
            ;;
    esac
}

main "$@"
