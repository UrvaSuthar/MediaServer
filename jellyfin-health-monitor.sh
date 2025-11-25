#!/bin/bash

###############################################################################
# Jellyfin Health Monitor
# Continuously monitor Jellyfin health and send alerts
###############################################################################

set -euo pipefail

readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

readonly CHECK_INTERVAL=60  # seconds
readonly LOG_FILE="${HOME}/jellyfin-server/health-monitor.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "${LOG_FILE}"
}

check_docker() {
    if ! docker ps | grep -q jellyfin; then
        return 1
    fi
    return 0
}

check_http() {
    if curl -sf "http://localhost:8096/health" > /dev/null 2>&1; then
        return 0
    fi
    return 1
}

check_disk_space() {
    local available=$(df -k "${HOME}" | tail -1 | awk '{print $4}')
    local threshold=1048576  # 1GB in KB
    
    if (( available < threshold )); then
        return 1
    fi
    return 0
}

send_notification() {
    local title="$1"
    local message="$2"
    
    # macOS notification
    osascript -e "display notification \"${message}\" with title \"${title}\""
}

monitor_loop() {
    log "Health monitor started"
    
    local consecutive_failures=0
    local max_failures=3
    
    while true; do
        local all_healthy=true
        
        # Check Docker container
        if ! check_docker; then
            log "WARNING: Jellyfin container not running"
            all_healthy=false
        fi
        
        # Check HTTP endpoint
        if ! check_http; then
            log "WARNING: Jellyfin not responding to HTTP requests"
            all_healthy=false
        fi
        
        # Check disk space
        if ! check_disk_space; then
            log "WARNING: Low disk space detected"
            send_notification "Jellyfin Warning" "Low disk space detected"
        fi
        
        # Handle failures
        if [[ "${all_healthy}" == "false" ]]; then
            ((consecutive_failures++))
            
            if (( consecutive_failures >= max_failures )); then
                log "CRITICAL: Jellyfin unhealthy for ${consecutive_failures} checks"
                send_notification "Jellyfin Alert" "Server is unhealthy!"
            fi
        else
            if (( consecutive_failures > 0 )); then
                log "INFO: Jellyfin recovered"
                send_notification "Jellyfin" "Server recovered"
            fi
            consecutive_failures=0
        fi
        
        sleep "${CHECK_INTERVAL}"
    done
}

# Main
case "${1:-}" in
    start)
        monitor_loop
        ;;
    daemon)
        nohup "$0" start > /dev/null 2>&1 &
        echo "Health monitor started in background"
        ;;
    stop)
        pkill -f "jellyfin-health-monitor" || true
        echo "Health monitor stopped"
        ;;
    *)
        echo "Usage: $0 {start|daemon|stop}"
        exit 1
        ;;
esac
