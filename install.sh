#!/bin/bash

echo "[+] Installing WITCH repository..."

REPO_URL="https://kingmsh1.github.io/Witch/"

# Add repo list file
echo "deb [trusted=yes] $REPO_URL ./" \
| sudo tee /etc/apt/sources.list.d/witch.list > /dev/null

echo "[+] Updating package lists..."
sudo apt update

echo "[+] Installing witch v1.0.0..."
sudo apt install -y witch

echo "[+] Installation complete!"
echo "[+] Run: witch --help"
