#!/bin/bash

echo "[+] Installing Witch..."

mkdir -p /usr/share/witch

if [ ! -f /usr/share/witch/directorywordlistmedium.txt ]; then
    echo "[+] Installing wordlist..."

    curl -sSL https://raw.githubusercontent.com/Kingmsh1/Witch/main/witch_1.0_all.deb/usr/share/witch/directorywordlistmedium.txt \
        -o /usr/share/witch/directorywordlistmedium.txt
else
    echo "[+] Wordlist already installed."
fi

echo "[+] Installing binary..."

curl -sSL https://raw.githubusercontent.com/Kingmsh1/Witch/main/witch_1.0_all.deb/usr/bin/witch \
    -o /tmp/witch

chmod +x /tmp/witch
mv /tmp/witch /usr/bin/witch

if command -v witch >/dev/null 2>&1; then
    echo "[+] Witch installed successfully!"
    echo "[+] Run with: witch"
else
    echo "[!] Installation failed: witch not found in PATH"
    exit 1
fi
