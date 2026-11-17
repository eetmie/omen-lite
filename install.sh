#!/bin/sh
# Install the 75 W hp-wmi driver (DKMS) and the omen-lite fan CLI. Run with: sudo ./install.sh
set -e
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }
cd "$(dirname "$0")"
[ "$(cat /sys/class/dmi/id/board_name)" = 8E41 ] || { echo "board is not 8E41; this driver patch is only for that board"; exit 1; }

NAME=hp-wmi-omen8e41
VER=$(sed -n 's/^PACKAGE_VERSION="\(.*\)"/\1/p' hp-wmi/dkms.conf)
command -v dkms >/dev/null || apt-get install -y dkms
dkms remove "$NAME/$VER" --all 2>/dev/null || true   # reinstall over an older copy
rm -rf "/usr/src/$NAME-$VER"
cp -r hp-wmi "/usr/src/$NAME-$VER"
dkms install "$NAME/$VER"

cat > /etc/modprobe.d/omen-8e41-gpu.conf <<'CONF'
# omen-lite: 75 W GPU budget in Performance on OMEN 8E41.
# saver_dstate: GPU throttle level in Power Saver, measured on battery 1=40 W 2=35 W 3=25 W 4=20 W 5=10 W
options hp_wmi omen_8e41_gpu_boost=1 omen_8e41_saver_dstate=5
CONF
install -Dm755 omen-lite /usr/local/bin/omen-lite

# Secure Boot: DKMS signs with this key; the firmware must trust it.
KEY=/var/lib/shim-signed/mok/MOK.der
if mokutil --sb-state 2>/dev/null | grep -q enabled && ! mokutil --test-key "$KEY" 2>/dev/null | grep -q 'already enrolled'; then
    echo "Secure Boot is on: set a one-time password now, then choose 'Enroll MOK' on the blue screen at the next boot."
    mokutil --import "$KEY"
fi
echo "Installed. Reboot, then check: cat /sys/devices/platform/hp-wmi/omen_gpu_power"
