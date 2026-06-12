#!/bin/bash

echo "[+] Installing Witch..."

INSTALL_PATH="/usr/bin/witch"
WORDLIST_PATH="/usr/share/witch/directorywordlistmedium.txt"

mkdir -p /usr/share/witch

echo "[+] Installing wordlist..."

curl -sSL "https://raw.githubusercontent.com/Kingmsh1/Witch/main/witch-deb/usr/share/witch/directorywordlistmedium.txt" -o "$WORDLIST_PATH"

echo "[+] Installing main binary..."

TMP_FILE="/tmp/witch"

curl -sSL "https://raw.githubusercontent.com/Kingmsh1/Witch/main/witch-deb/usr/bin/witch" -o "$TMP_FILE"

if [[ ! -s "$TMP_FILE" ]]; then
    echo "[!] Download failed! Binary is empty or missing"
    exit
fi

chmod +x "$TMP_FILE"
mv "$TMP_FILE" "$INSTALL_PATH"

if command -v witch >/dev/null 2>&1; then
    echo "[+] Witch installed successfully!"
    echo "[+] Run with: witch"
else
    echo "[!] Installation failed! Command not found in PATH"
    exit 
fi
