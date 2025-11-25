#!/bin/bash

###############################################################################
# Jellyfin AI Setup
# Configures Ollama AI for smart media recommendations
###############################################################################

set -euo pipefail

readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

echo "=========================================="
echo "  Jellyfin AI Assistant Setup"
echo "=========================================="
echo ""

# Start AI services
echo -e "${BLUE}Starting AI services...${NC}"
cd ~/jellyfin-server
docker compose up -d ollama open-webui

echo ""
echo "Waiting for Ollama to start..."
sleep 10

# Download AI model
echo -e "${BLUE}Downloading AI model (this may take a few minutes)...${NC}"
docker exec jellyfin-ai ollama pull llama3.2

echo ""
echo "=========================================="
echo -e "${GREEN}AI Setup Complete!${NC}"
echo "=========================================="
echo ""
echo -e "${BOLD}Access Points:${NC}"
echo ""
echo "🤖 AI Chat Interface:"
echo "   http://localhost:3000"
echo ""
echo "🔌 AI API:"
echo "   http://localhost:11434"
echo ""
echo -e "${BOLD}What You Can Do:${NC}"
echo ""
echo "1. Ask for movie recommendations"
echo "2. Search your media library intelligently"
echo "3. Get summaries of movies/shows"
echo "4. Natural language queries about your content"
echo ""
echo -e "${BOLD}Example Prompts:${NC}"
echo '  "Recommend a thriller movie for tonight"'
echo '  "What comedies do I have from the 90s?"'
echo '  "Summarize the plot of Inception"'
echo ""
echo "=========================================="
