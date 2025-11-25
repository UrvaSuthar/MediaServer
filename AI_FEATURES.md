# 🤖 AI Features for Jellyfin

## Overview

Your Jellyfin media server now includes **AI-powered features** using Ollama (local, free, private AI).

## What's Included

### 1. 🤖 Ollama AI Engine
- **Local AI** - Runs on your laptop, no cloud needed
- **100% Private** - Your data never leaves your machine
- **Free** forever
- **Fast responses** - Optimized for M-series Macs

### 2. 💬 AI Chat Interface
- Beautiful web UI for chatting with AI
- Ask about your media library
- Get recommendations
- Search intelligently

### 3. 🎬 Smart Features
- Movie/TV recommendations based on mood
- Intelligent media search
- Plot summaries
- Similar content suggestions

---

## Quick Start

### Setup AI (One Time)

```bash
# Start AI services and download model
bash setup-ai.sh
```

This will:
1. Start Ollama AI engine
2. Start Web UI
3. Download Llama 3.2 model (~2GB)

**Time**: ~5 minutes (depending on internet speed)

### Access Points

- **AI Chat**: http://localhost:3000
- **Jellyfin**: http://localhost:8096
- **AI API**: http://localhost:11434

---

## Usage Examples

### In AI Chat Interface

**Get Recommendations:**
```
"I want to watch a thriller movie tonight, what do you recommend?"
```

**Search Your Library:**
```
"What sci-fi movies do I have from the 2010s?"
```

**Get Information:**
```
"Tell me about Inception - plot summary and themes"
```

**Mood-Based:**
```
"I'm feeling nostalgic, suggest some 90s comedies"
```

### Via API (for developers)

```bash
# Ask AI about movies
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2",
  "prompt": "Recommend a good action movie"
}'
```

---

## AI Models Available

### Default: Llama 3.2 (1.3GB)
- **Best for**: General recommendations, chat
- **Speed**: Very fast  
- **Accuracy**: Good

### Optional Models

```bash
# For better movie knowledge
docker exec jellyfin-ai ollama pull mistral

# For coding/technical help
docker exec jellyfin-ai ollama pull codellama

# List installed models
docker exec jellyfin-ai ollama list
```

---

## Advanced Features

### 1. Create Custom Movie Assistant

Train the AI on your specific preferences:

```
Open AI Chat → Settings → Create new persona:
- Name: "Movie Guru"
- Instructions: "You are a movie expert who knows my library. 
  I like thrillers, sci-fi, and classic films. 
  Always check if I own a movie before recommending it."
```

### 2. Integrate with Jellyfin

Use the AI API to enhance Jellyfin:

```javascript
// Get movie recommendation
fetch('http://localhost:11434/api/generate', {
  method: 'POST',
  body: JSON.stringify({
    model: 'llama3.2',
    prompt: 'Recommend a movie similar to ' + currentMovie
  })
})
```

### 3. Voice Commands (with Shortcuts app)

Create iPhone shortcut:
1. Speak text → Send to AI API
2. Get recommendation
3. Open Jellyfin app

---

## Management

### Start/Stop AI

```bash
# Start AI services
cd ~/jellyfin-server
docker compose up -d ollama open-webui

# Stop AI services (saves resources)
docker compose stop ollama open-webui

# Restart AI
docker compose restart ollama open-webui
```

### Update AI Models

```bash
# Update to latest model
docker exec jellyfin-ai ollama pull llama3.2

# Remove old models
docker exec jellyfin-ai ollama rm <model-name>
```

### Check AI Status

```bash
# View AI logs
docker compose logs -f ollama

# Check AI health
curl http://localhost:11434/api/tags
```

---

## Resource Usage

**Disk Space:**
- Ollama: ~500MB
- Llama 3.2 model: ~1.3GB
- Web UI: ~200MB
- **Total**: ~2GB

**Memory:**
- Idle: ~500MB
- Active: ~2GB
- Peak: ~4GB (with large requests)

**CPU:**
- Optimized for Apple Silicon
- Uses GPU acceleration when available

---

## Privacy & Security

✅ **100% Local** - AI runs on your laptop  
✅ **No Cloud** - Nothing sent to external servers  
✅ **Private** - Your queries stay private  
✅ **Offline** - Works without internet (after model download)  

---

## Troubleshooting

### AI not responding

```bash
# Check if running
docker ps | grep ollama

# Restart
docker compose restart ollama

# View logs
docker compose logs ollama
```

### Model download failed

```bash
# Retry download
docker exec jellyfin-ai ollama pull llama3.2

# Or use smaller model
docker exec jellyfin-ai ollama pull tinyllama
```

### Out of memory

```bash
# Use smaller model
docker exec jellyfin-ai ollama pull tinyllama

# Or stop AI when not in use
docker compose stop ollama open-webui
```

---

## Future Enhancements

Coming soon:
- [ ] Automatic subtitle generation (Whisper AI)
- [ ] Smart media organization
- [ ] AI-powered watchlist
- [ ] Mood-based playlists
- [ ] Voice control integration

---

## Examples

### Family Movie Night

**You:** "Suggest a family-friendly movie for ages 6-12"

**AI:** "Based on your preferences, I recommend:
1. The Lion King (if you have it)
2. Finding Nemo
3. Toy Story series

Would you like more details about any of these?"

### Weekend Binge

**You:** "I have 8 hours this weekend, recommend a series to binge"

**AI:** "Perfect! Here are some binge-worthy options:
- Breaking Bad (if you haven't seen it)
- Stranger Things
- The Office

Which genre are you in the mood for?"

---

## Cost

**Total Cost: $0**

- Ollama: Free & Open Source
- All models: Free
- Web UI: Free
- Hosting: Local (your laptop)

---

Ready to try it? Run: `bash setup-ai.sh`
