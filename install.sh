#!/bin/sh
# Install OMEN Lite. Run with: sudo ./install.sh
set -e
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }
cd "$(dirname "$0")"
install -Dm755 omen-lite-helper /usr/local/libexec/omen-lite-helper
install -Dm755 omen-lite        /usr/local/bin/omen-lite
install -Dm644 local.omenlite.policy /usr/share/polkit-1/actions/local.omenlite.policy
install -Dm644 omen-lite.service /etc/systemd/system/omen-lite.service
install -Dm644 omen-lite.desktop /usr/local/share/applications/omen-lite.desktop
systemctl daemon-reload
systemctl enable omen-lite.service
systemctl restart omen-lite.service   # pick up a new helper on reinstall
echo "Installed. Open 'OMEN Lite' from the app menu, or run: omen-lite status"
