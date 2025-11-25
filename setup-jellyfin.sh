#!/bin/bash

###############################################################################
# Jellyfin Media Server - Advanced Setup Script
# 
# Features:
# - Comprehensive error checking
# - Configurable via environment variables
# - Backup and restore capabilities
# - Health checks and validation
# - Detailed logging
#
# Usage: bash setup-jellyfin.sh [OPTIONS]
# Options:
#   --skip-docker-check    Skip Docker installation check
#   --custom-media-dir     Specify custom media directory
#   --custom-config-dir    Specify custom config directory
#   --no-start             Don't start services after setup
#   --help                 Show this help message
###############################################################################

set -euo pipefail  # Exit on error, undefined vars, pipe failures
IFS=$'\n\t'

# Colors and formatting
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color
readonly BOLD='\033[1m'

# Script configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="${SCRIPT_DIR}/setup.log"
readonly BACKUP_DIR="${SCRIPT_DIR}/backups"

# Default configuration
MEDIA_DIR="${HOME}/Media"
CONFIG_DIR="${HOME}/jellyfin-config"
SETUP_DIR="${HOME}/jellyfin-server"
SKIP_DOCKER_CHECK=false
NO_START=false

###############################################################################
# Logging functions
###############################################################################

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "${LOG_FILE}"
}

log_info() {
    echo -e "${BLUE}ℹ${NC} $*" | tee -a "${LOG_FILE}"
}

log_success() {
    echo -e "${GREEN}✓${NC} $*" | tee -a "${LOG_FILE}"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $*" | tee -a "${LOG_FILE}"
}

log_error() {
    echo -e "${RED}✗${NC} $*" | tee -a "${LOG_FILE}"
}

###############################################################################
# Helper functions
###############################################################################

print_header() {
    echo ""
    echo -e "${CYAN}${BOLD}========================================${NC}"
    echo -e "${CYAN}${BOLD}  Jellyfin Media Server - Setup${NC}"
    echo -e "${CYAN}${BOLD}  Advanced Installation Script${NC}"
    echo -e "${CYAN}${BOLD}========================================${NC}"
    echo ""
}

print_help() {
    cat << EOF
Usage: bash setup-jellyfin.sh [OPTIONS]

Options:
    --skip-docker-check       Skip Docker installation check
    --custom-media-dir DIR    Specify custom media directory
    --custom-config-dir DIR   Specify custom config directory
    --no-start                Don't start services after setup
    --help                    Show this help message

Examples:
    bash setup-jellyfin.sh
    bash setup-jellyfin.sh --custom-media-dir /Volumes/External/Media
    bash setup-jellyfin.sh --no-start

EOF
}

check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

###############################################################################
# Validation functions
###############################################################################

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check OS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_warning "This script is optimized for macOS. Continuing anyway..."
    fi
    
    # Check Docker
    if [[ "${SKIP_DOCKER_CHECK}" == "false" ]]; then
        if ! check_command docker; then
            log_error "Docker is not installed"
            echo ""
            echo "Please install Docker Desktop from:"
            echo "https://www.docker.com/products/docker-desktop"
            exit 1
        fi
        log_success "Docker is installed"
        
        # Check if Docker is running
        if ! docker info &> /dev/null; then
            log_error "Docker is not running"
            echo "Please start Docker Desktop and try again"
            exit 1
        fi
        log_success "Docker is running"
    fi
    
    # Check available disk space
    local available_space=$(df -k "${HOME}" | tail -1 | awk '{print $4}')
    local required_space=5242880  # 5GB in KB
    
    if (( available_space < required_space )); then
        log_warning "Low disk space detected (less than 5GB available)"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

###############################################################################
# Setup functions
###############################################################################

create_directory_structure() {
    log_info "Creating directory structure..."
    
    # Create media directories
    mkdir -p "${MEDIA_DIR}"/{movies,tv-shows,music,photos}
    log_success "Media directory: ${MEDIA_DIR}"
    
    # Create config directories
    mkdir -p "${CONFIG_DIR}"/{config,cache,logs}
    log_success "Config directory: ${CONFIG_DIR}"
    
    # Create setup directory
    mkdir -p "${SETUP_DIR}"
    log_success "Setup directory: ${SETUP_DIR}"
    
    # Create backup directory
    mkdir -p "${BACKUP_DIR}"
    
    # Set permissions
    chmod 755 "${MEDIA_DIR}"
    chmod 755 "${CONFIG_DIR}"
}

generate_env_file() {
    log_info "Generating environment file..."
    
    local env_file="${SETUP_DIR}/.env"
    
    cat > "${env_file}" <<EOF
# Jellyfin Configuration
# Generated on $(date)

# Server Settings
JELLYFIN_VERSION=latest
JELLYFIN_PORT=8096
JELLYFIN_HTTPS_PORT=8920
TZ=Asia/Kolkata

# Directory Paths
MEDIA_DIR=${MEDIA_DIR}
CONFIG_DIR=${CONFIG_DIR}

# Network Settings
PUBLISHED_SERVER_URL=http://localhost:8096

# Restart Policy
RESTART_POLICY=unless-stopped
EOF
    
    log_success "Environment file created: ${env_file}"
}

copy_docker_compose() {
    log_info "Setting up Docker Compose configuration..."
    
    if [[ -f "${SCRIPT_DIR}/docker-compose.yml" ]]; then
        cp "${SCRIPT_DIR}/docker-compose.yml" "${SETUP_DIR}/"
        log_success "Docker Compose file copied"
    else
        log_error "docker-compose.yml not found in script directory"
        exit 1
    fi
}

start_services() {
    if [[ "${NO_START}" == "true" ]]; then
        log_info "Skipping service start (--no-start flag)"
        return
    fi
    
    log_info "Starting Jellyfin services..."
    
    cd "${SETUP_DIR}"
    docker compose up -d
    
    log_success "Services started"
    
    # Wait for service to be healthy
    log_info "Waiting for Jellyfin to be ready..."
    local max_attempts=30
    local attempt=0
    
    while (( attempt < max_attempts )); do
        if curl -sf "http://localhost:8096/health" > /dev/null 2>&1; then
            log_success "Jellyfin is ready!"
            return
        fi
        ((attempt++))
        sleep 2
    done
    
    log_warning "Could not verify Jellyfin health. It may still be starting up."
}

display_summary() {
    local wifi_ip=$(ipconfig getifaddr en0 2>/dev/null || echo "Not connected")
    
    echo ""
    echo -e "${GREEN}${BOLD}========================================${NC}"
    echo -e "${GREEN}${BOLD}  Setup Complete! 🎉${NC}"
    echo -e "${GREEN}${BOLD}========================================${NC}"
    echo ""
    
    echo -e "${BOLD}Access URLs:${NC}"
    echo "  📍 Local:   http://localhost:8096"
    if [[ "${wifi_ip}" != "Not connected" ]]; then
        echo "  📱 Network: http://${wifi_ip}:8096"
    fi
    echo ""
    
    echo -e "${BOLD}Media Directories:${NC}"
    echo "  🎬 Movies:   ${MEDIA_DIR}/movies/"
    echo "  📺 TV Shows: ${MEDIA_DIR}/tv-shows/"
    echo "  🎵 Music:    ${MEDIA_DIR}/music/"
    echo "  📸 Photos:   ${MEDIA_DIR}/photos/"
    echo ""
    
    echo -e "${BOLD}Useful Commands:${NC}"
    echo "  Start:  cd ${SETUP_DIR} && docker compose up -d"
    echo "  Stop:   cd ${SETUP_DIR} && docker compose down"
    echo "  Logs:   cd ${SETUP_DIR} && docker compose logs -f"
    echo ""
    
    echo -e "${BOLD}Next Steps:${NC}"
    echo "  1. Open http://localhost:8096 in your browser"
    echo "  2. Complete the setup wizard"
    echo "  3. Add media files to ${MEDIA_DIR}"
    echo ""
    
    echo "Setup log: ${LOG_FILE}"
    echo ""
}

###############################################################################
# Backup functions
###############################################################################

create_backup() {
    local backup_name="jellyfin-backup-$(date +%Y%m%d_%H%M%S).tar.gz"
    local backup_path="${BACKUP_DIR}/${backup_name}"
    
    log_info "Creating backup..."
    
    if [[ -d "${CONFIG_DIR}/config" ]]; then
        tar -czf "${backup_path}" -C "${CONFIG_DIR}" config
        log_success "Backup created: ${backup_path}"
    else
        log_warning "No configuration to backup"
    fi
}

###############################################################################
# Main execution
###############################################################################

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-docker-check)
                SKIP_DOCKER_CHECK=true
                shift
                ;;
            --custom-media-dir)
                MEDIA_DIR="$2"
                shift 2
                ;;
            --custom-config-dir)
                CONFIG_DIR="$2"
                shift 2
                ;;
            --no-start)
                NO_START=true
                shift
                ;;
            --help)
                print_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                print_help
                exit 1
                ;;
        esac
    done
    
    # Start setup
    print_header
    log "Setup started by $(whoami) on $(hostname)"
    
    # Execute setup steps
    check_prerequisites
    create_directory_structure
    generate_env_file
    copy_docker_compose
    start_services
    
    # Display summary
    display_summary
    
    log "Setup completed successfully"
}

# Run main function
main "$@"
