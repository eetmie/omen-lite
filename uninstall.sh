#!/bin/sh
# Remove the driver and fan CLI, back to the stock hp-wmi. Run with: sudo ./uninstall.sh
set -e
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }
/usr/local/bin/omen-lite fan auto 2>/dev/null || true
dkms remove hp-wmi-omen8e41 --all 2>/dev/null || true
rm -rf /usr/src/hp-wmi-omen8e41-*
rm -f /etc/modprobe.d/omen-8e41-gpu.conf /usr/local/bin/omen-lite
echo "Removed. Reboot to load the stock driver."
