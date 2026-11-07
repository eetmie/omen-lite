#!/bin/sh
# Remove OMEN Lite and set fans back to automatic. Run with: sudo ./uninstall.sh
set -e
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }
systemctl disable --now omen-lite.service 2>/dev/null || true
/usr/local/libexec/omen-lite-helper fan auto 2>/dev/null || true
rm -f /usr/local/libexec/omen-lite-helper /usr/local/bin/omen-lite \
      /usr/share/polkit-1/actions/local.omenlite.policy \
      /etc/systemd/system/omen-lite.service \
      /usr/local/share/applications/omen-lite.desktop
rm -rf /var/lib/omen-lite
systemctl daemon-reload
echo "Removed."
