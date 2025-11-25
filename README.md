# 🎬 Jellyfin Media Server - Advanced Setup (Backup Branch)

<div align="center">

**Enterprise-grade media server setup with advanced features**

[![Docker](https://img.shields.io/badge/Docker-Required-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Jellyfin](https://img.shields.io/badge/Jellyfin-Latest-00A4DC?logo=jellyfin&logoColor=white)](https://jellyfin.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[Features](#-advanced-features) • [Quick Start](#-quick-start) • [Management](#-server-management) • [Monitoring](#-health-monitoring) • [Architecture](#-architecture)

</div>

---

## 📖 Overview

This is the **advanced/backup branch** with enterprise-grade features for production deployments. It includes comprehensive error handling, automated backups, health monitoring, and management tools.

### Main Branch vs Backup Branch

| Feature | Main Branch | Backup Branch (This) |
|---------|-------------|---------------------|
| Setup Complexity | Simple | Advanced |
| Error Handling | Basic | Comprehensive |
| Logging | Minimal | Detailed |
| Backups | Manual | Automated |
| Health Monitoring | None | Built-in |
| Configuration | Hardcoded | Environment-based |
| Management Tools | Basic | Full CLI |
| Resource Limits | None | Configurable |
| Production Ready | Good | Excellent |

---

## ✨ Advanced Features

### 🔧 Enhanced Setup Script
- ✅ Comprehensive prerequisite checks
- ✅ Configurable via environment variables
- ✅ Detailed logging to `setup.log`
- ✅ Automatic backup before changes
- ✅ Disk space validation
- ✅ Command-line options support
- ✅ Health check verification

### 📊 Management CLI
Complete management tool (`jellyfin-manage.sh`):
- Start/stop/restart server
- View logs (live or historical)
- Automatic updates
- Backup/restore configuration
- Cache cleaning
- Status monitoring
- Address lookup

### 🏥 Health Monitoring
Continuous monitoring with alerts (`jellyfin-health-monitor.sh`):
- Docker container health
- HTTP endpoint checks
- Disk space monitoring
- macOS notifications
- Automatic recovery attempts
- Detailed health logs

### 🐳 Advanced Docker Configuration
- Environment-based configuration
- Resource limits (CPU/Memory)
- Health checks built-in
- Logging rotation
- Network isolation
- Optional Watchtower auto-updates

---

## 🚀 Quick Start

### Prerequisites

- macOS 12+ (optimized for Apple Silicon)
- Docker Desktop installed and running
- 5GB+ available disk space

### Installation

```bash
# Clone repository
git clone -b backup https://github.com/UrvaSuthar/MediaServer.git
cd MediaServer

# Run advanced setup
bash setup-jellyfin.sh
```

### With Custom Options

```bash
# Custom directories
bash setup-jellyfin.sh \
  --custom-media-dir /Volumes/External/Media \
  --custom-config-dir /Volumes/External/jellyfin-config

# Setup without starting (for configuration review)
bash setup-jellyfin.sh --no-start

# View all options
bash setup-jellyfin.sh --help
```

---

## 🛠️ Server Management

Use the comprehensive management tool:

```bash
# Start server
bash jellyfin-manage.sh start

# Stop server
bash jellyfin-manage.sh stop

# Restart server
bash jellyfin-manage.sh restart

# Check status
bash jellyfin-manage.sh status

# View logs (live)
bash jellyfin-manage.sh logs -f

# Update to latest version
bash jellyfin-manage.sh update

# Create backup
bash jellyfin-manage.sh backup

# Restore from backup
bash jellyfin-manage.sh restore ~/jellyfin-server/backups/jellyfin-config-20250126.tar.gz

# Clean cache and old data
bash jellyfin-manage.sh clean

# Get all server addresses
bash jellyfin-manage.sh addresses
```

---

## 🏥 Health Monitoring

Start continuous health monitoring:

```bash
# Run in foreground (for testing)
bash jellyfin-health-monitor.sh start

# Run as daemon (background)
bash jellyfin-health-monitor.sh daemon

# Stop monitor
bash jellyfin-health-monitor.sh stop
```

**What it monitors:**
- ✅ Docker container status
- ✅ HTTP health endpoint
- ✅ Disk space availability
- ✅ Sends macOS notifications on issues
- ✅ Automatic recovery attempts

Logs are saved to: `~/jellyfin-server/health-monitor.log`

---

## ⚙️ Configuration

### Environment Variables

Create `.env` file (auto-generated from `.env.example`):

```bash
# Server Settings
JELLYFIN_VERSION=latest          # Docker image version
JELLYFIN_PORT=8096               # HTTP port
JELLYFIN_HTTPS_PORT=8920         # HTTPS port
TZ=Asia/Kolkata                  # Timezone

# Directories
MEDIA_DIR=/Users/you/Media
CONFIG_DIR=/Users/you/jellyfin-config

# Network
PUBLISHED_SERVER_URL=http://localhost:8096

# Restart Policy
RESTART_POLICY=unless-stopped    # always, on-failure, no
```

### Docker Compose Features

The advanced `docker-compose.yml` includes:

```yaml
# Resource limits
deploy:
  resources:
    limits:
      cpus: '2'
      memory: 4G

# Health checks
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8096/health"]
  interval: 30s

# Logging rotation
logging:
  options:
    max-size: "10m"
    max-file: "3"
```

Uncomment sections in `docker-compose.yml` to enable.

---

## 📂 Architecture

### Directory Structure

```
~/jellyfin-server/          # Main setup directory
├── docker-compose.yml      # Docker configuration
├── .env                    # Environment variables
├── .env.example           # Environment template
├── setup-jellyfin.sh      # Setup script
├── jellyfin-manage.sh     # Management CLI
├── jellyfin-health-monitor.sh  # Health monitoring
├── setup.log              # Setup logs
└── backups/               # Configuration backups
    └── jellyfin-config-*.tar.gz

~/jellyfin-config/         # Jellyfin data
├── config/                # Server configuration
├── cache/                 # Transcoding cache
└── logs/                  # Server logs

~/Media/                   # Your media files
├── movies/
├── tv-shows/
├── music/
└── photos/
```

### Logging

- **Setup logs**: `~/jellyfin-server/setup.log`
- **Health monitoring**: `~/jellyfin-server/health-monitor.log`
- **Docker logs**: `docker compose logs jellyfin`
- **Jellyfin logs**: `~/jellyfin-config/logs/`

---

## 🔄 Automated Backups

### Schedule Regular Backups

Add to crontab:

```bash
# Open crontab
crontab -e

# Add daily backup at 3 AM
0 3 * * * cd ~/jellyfin-server && bash jellyfin-manage.sh backup

# Add weekly cleanup
0 4 * * 0 cd ~/jellyfin-server && bash jellyfin-manage.sh clean
```

### Manual Backup

```bash
# Create backup
bash jellyfin-manage.sh backup

# List backups
ls -lh ~/jellyfin-server/backups/

# Restore specific backup
bash jellyfin-manage.sh restore ~/jellyfin-server/backups/jellyfin-config-20250126_120000.tar.gz
```

**Note**: Backup script keeps only the last 5 backups automatically.

---

## 🚀 Production Deployment

### Security Checklist

- [ ] Change default admin password
- [ ] Enable HTTPS (configure reverse proxy)
- [ ] Set up firewall rules
- [ ] Configure Tailscale for remote access
- [ ] Enable resource limits in docker-compose.yml
- [ ] Set up automated backups (cron)
- [ ] Enable health monitoring daemon
- [ ] Review and restrict user permissions

### Performance Optimization

```yaml
# In docker-compose.yml, uncomment:
deploy:
  resources:
    limits:
      cpus: '4'        # Adjust based on your CPU
      memory: 8G       # More RAM = better transcoding
```

### Auto-Updates

Enable Watchtower in `docker-compose.yml` for automatic updates:

```bash
# Uncomment watchtower service in docker-compose.yml
# Then restart
bash jellyfin-manage.sh restart
```

---

## 📊 Monitoring & Alerts

### Check Server Health

```bash
# Quick status
bash jellyfin-manage.sh status

# Detailed info
docker stats jellyfin

# Resource usage
docker exec jellyfin top
```

### macOS Notifications

Health monitor sends notifications for:
- 🔴 Server down
- 💾 Low disk space  
- ✅ Server recovered

---

## 🆘 Troubleshooting

### View Logs

```bash
# Setup issues
cat ~/jellyfin-server/setup.log

# Runtime issues
bash jellyfin-manage.sh logs -f

# Health monitoring
cat ~/jellyfin-server/health-monitor.log
```

### Common Issues

<details>
<summary><b>Setup fails with permission error</b></summary>

```bash
#Fix permissions
chmod +x setup-jellyfin.sh jellyfin-manage.sh jellyfin-health-monitor.sh

# Run setup again
bash setup-jellyfin.sh
```
</details>

<details>
<summary><b>Server won't start</b></summary>

```bash
# Check Docker
docker info

# Check logs
bash jellyfin-manage.sh logs

# Clean and restart
bash jellyfin-manage.sh clean
bash jellyfin-manage.sh start
```
</details>

<details>
<summary><b>Health monitor not sending notifications</b></summary>

Ensure System Preferences → Notifications → Script Editor is enabled for notifications.
</details>

---

## 🔍 Advanced Usage

### Custom Network Configuration

Edit `docker-compose.yml`:

```yaml
networks:
  jellyfin-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

### Integration with Reverse Proxy

Example Nginx configuration:

```nginx
location /jellyfin {
    proxy_pass http://localhost:8096;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

---

## 🔬 Development

### Testing Changes

```bash
# Test setup script
bash setup-jellyfin.sh --no-start --custom-media-dir /tmp/test-media

# Test management commands
bash jellyfin-manage.sh status
bash jellyfin-manage.sh backup
```

### Contributing

1. Fork the repository
2. Create feature branch from `backup`
3. Make changes
4. Test thoroughly
5. Submit pull request

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file

---

## 🙏 Acknowledgments

- [Jellyfin](https://jellyfin.org/) - Media server
- [Docker](https://www.docker.com/) - Containerization
- [Tailscale](https://tailscale.com/) - VPN solution

---

<div align="center">

**Enterprise-grade media server management** ⭐

Made with ❤️ for production deployments

[⬆ Back to Top](#-jellyfin-media-server---advanced-setup-backup-branch)

</div>
