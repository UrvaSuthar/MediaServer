# 🎬 Jellyfin Media Server - One-Command Setup

<div align="center">

**Set up your own Netflix-like media server in under 2 minutes!**

[![Docker](https://img.shields.io/badge/Docker-Required-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Jellyfin](https://img.shields.io/badge/Jellyfin-Latest-00A4DC?logo=jellyfin&logoColor=white)](https://jellyfin.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-Compatible-000000?logo=apple&logoColor=white)](https://www.apple.com/macos/)

[Features](#-features) • [Quick Start](#-quick-start) • [Usage](#-usage) • [Remote Access](#-remote-access) • [Troubleshooting](#-troubleshooting)

</div>

---

## 📖 Overview

This repository provides a **fully automated** Jellyfin media server setup with just one command. Perfect for sharing movies, TV shows, music, and photos with family and friends across the internet!

### What is Jellyfin?

Jellyfin is a free, open-source media server that lets you stream your personal media collection anywhere. Think of it as your own Netflix, but you control everything!

### Why This Project?

- ✅ **One-command setup** - No manual configuration needed
- ✅ **100% Free** - No subscriptions or hidden costs
- ✅ **Remote access ready** - Share with family anywhere via Tailscale VPN
- ✅ **Watch parties** - Synchronized viewing with SyncPlay
- ✅ **Auto-configured** - Plugins and libraries set up automatically

---

## ✨ Features

- 🚀 **Automated Installation** - Complete setup in one command
- 📱 **Mobile Friendly** - Access from phones, tablets, Smart TVs
- 🎭 **Rich Metadata** - Automatic movie/TV show posters and info (TMDb)
- ⏭️ **Intro Skipper** - Automatically skip TV show intros
- 📊 **Playback Tracking** - Resume watching from where you left off
- 👥 **Multi-User** - Create accounts for family members
- 🎉 **Watch Parties** - Watch together in perfect sync (SyncPlay)
- 🔒 **Secure Remote Access** - VPN-based remote streaming (Tailscale)
- 🎨 **Beautiful Interface** - Modern, responsive web UI
- 🔄 **Auto-Updates** - Easy one-command updates

---

## 🚀 Quick Start

### Prerequisites

- **macOS** (tested on macOS 12+)
- **Docker Desktop** ([Download here](https://www.docker.com/products/docker-desktop))
- **5 minutes** of your time ⏱️

### Installation

```bash
# Clone this repository
git clone https://github.com/YOUR_USERNAME/jellyfin-one-command.git
cd jellyfin-one-command

# Run the setup script
bash setup-jellyfin.sh
```

That's it! ✨ The script will automatically:
1. ✅ Verify Docker is installed and running
2. ✅ Create media directories
3. ✅ Generate configuration files
4. ✅ Start Jellyfin server
5. ✅ Display all access URLs

---

## 🎬 Usage

### Accessing Your Server

After installation, open your browser:

- **Local**: http://localhost:8096
- **Same WiFi**: Run `bash get-server-address.sh` to get your network IP
- **Remote**: http://[tailscale-ip]:8096 (after Tailscale setup)

### Adding Media

Copy your files to the media directories:

```bash
# Movies
cp ~/Downloads/MyMovie.mp4 ~/Media/movies/

# TV Shows
cp -r ~/Downloads/MyTVShow/ ~/Media/tv-shows/
```

Jellyfin will automatically detect and add metadata!

---

## 📱 Remote Access Setup

**For family in different locations:**

1. Install Tailscale: `brew install tailscale && tailscale up`
2. Get your IP: `tailscale ip -4`
3. Install Tailscale on family's device
4. Share your Tailscale IP with them
5. They access: `http://[your-tailscale-ip]:8096`

🔐 **Secure & Free** - No port forwarding needed!

---

## 🛠️ Server Management

```bash
# Get server addresses
bash get-server-address.sh

# Start/Stop/Restart
cd ~/jellyfin-server
docker compose up -d
docker compose down
docker compose restart

# View logs
docker compose logs -f jellyfin

# Update server
docker compose pull && docker compose up -d
```

---

## 🆘 Troubleshooting

<details>
<summary><b>Server won't start</b></summary>

Check Docker is running: `docker info`
View logs: `docker compose logs jellyfin`
</details>

<details>
<summary><b>Can't access from phone</b></summary>

- Ensure phone is on same WiFi
- Run: `bash get-server-address.sh`
- Check firewall settings
</details>

<details>
<summary><b>Videos won't play</b></summary>

- Use MP4/MKV formats
- Wait 10-20 seconds for transcoding
- Enable hardware acceleration in settings
</details>

---

## 🙏 Acknowledgments

- [Jellyfin](https://jellyfin.org/) - Open-source media server
- [Tailscale](https://tailscale.com/) - VPN solution
- [Docker](https://www.docker.com/) - Containerization

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file

---

<div align="center">

**Made with ❤️ for media enthusiasts**

⭐ Star this repo if it helped you!

</div>
