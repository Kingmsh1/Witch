#!/bin/bash

echo "[+] Installing Witch..."

mkdir -p /usr/share/witch

if [ -f /usr/share/witch/directorywordlistmedium.txt ]; then
    echo "[+] Wordlist already installed."
else
    echo "[+] Installing wordlist..."
    cp -f /usr/share/witch-assets/directorywordlistmedium.txt /usr/share/witch/ 2>/dev/null || true
fi

chmod +x /usr/bin/witch 2>/dev/null || true

cp witch /usr/bin
chmod +x /usr/bin/witch

echo "[+] Witch installed successfully!"
echo "[+] Run with: witch"
