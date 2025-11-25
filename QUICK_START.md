# Jellyfin Media Server - Quick Start Guide

## 🚀 One-Command Setup

For a brand new installation, just run:

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_REPO/setup-jellyfin.sh | bash
```

Or if you have the script locally:

```bash
bash setup-jellyfin.sh
```

That's it! The script will:
- ✅ Check for Docker
- ✅ Create media directories
- ✅ Create configuration files
- ✅ Start Jellyfin server
- ✅ Show you the server address

---

## 📋 Manual Setup (Alternative)

If you prefer to do it manually:

```bash
# 1. Clone or download this repository
cd ~/jellyfin-server

# 2. Start the server
docker compose up -d

# 3. Get your server address
bash get-server-address.sh
```

---

## 📍 Finding Your Server Address

Run this anytime to see all your server addresses:

```bash
bash get-server-address.sh
```

Or manually:
- **Local**: http://localhost:8096
- **WiFi**: http://[your-wifi-ip]:8096
- **Remote**: http://[tailscale-ip]:8096

---

## 🎬 Adding Media

Copy your files to:
- **Movies**: `~/Media/movies/`
- **TV Shows**: `~/Media/tv-shows/`
- **Music**: `~/Media/music/`
- **Photos**: `~/Media/photos/`

Jellyfin will automatically scan and add them!

---

## 🛠️ Common Commands

```bash
# Start server
docker compose up -d

# Stop server
docker compose down

# View logs
docker compose logs -f jellyfin

# Check if running
docker ps | grep jellyfin

# Get server address
bash get-server-address.sh

# Update Jellyfin
docker compose pull && docker compose up -d
```

---

## 📱 Mobile Access

### Same WiFi Network:
1. Get your server IP: `bash get-server-address.sh`
2. On your phone, open: `http://[wifi-ip]:8096`

### Remote Access (Different Network):
1. Install Tailscale: `brew install tailscale`
2. Start Tailscale: `tailscale up`
3. Get Tailscale IP: `tailscale ip -4`
4. Install Tailscale on phone/TV
5. Access: `http://[tailscale-ip]:8096`

---

## 🎉 First Time Setup

After starting the server:
1. Open http://localhost:8096
2. Select your language
3. Create admin account (save this!)
4. Set up libraries (or skip and do later)
5. Install recommended plugins:
   - Intro Skipper
   - Playback Reporting
   - TMDb

---

## 🆘 Troubleshooting

**Server not starting?**
- Check Docker is running: `docker info`
- View logs: `docker compose logs jellyfin`

**Can't access from phone?**
- Make sure phone is on same WiFi
- Check firewall isn't blocking port 8096
- Try: `bash get-server-address.sh`

**Videos won't play?**
- Check file format (MP4/MKV work best)
- Wait for transcoding to start
- Enable hardware acceleration in settings

---

## 📦 What Gets Installed

```
~/Media/                    # Your media files
  ├── movies/
  ├── tv-shows/
  ├── music/
  └── photos/

~/jellyfin-config/          # Server configuration
  ├── config/
  ├── cache/
  └── logs/

~/jellyfin-server/          # Setup files
  ├── docker-compose.yml
  ├── setup-jellyfin.sh
  └── get-server-address.sh
```

---

## ⭐ Tips

- **Bulk import**: Copy entire folders to media directories
- **Watch together**: Use SyncPlay for synchronized viewing
- **User accounts**: Create separate accounts for family members
- **Backup**: Save `~/jellyfin-config/config/` regularly
- **Performance**: Enable hardware acceleration in Dashboard settings

Enjoy your personal Netflix! 🍿
