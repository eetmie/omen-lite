# OMEN Lite

Small power-mode and fan tool for the HP OMEN Transcend 14-fb1xxx (board 8E41).
It uses only the stock kernel `hp-wmi` driver and replaces no drivers.

## What it does
- **Power modes:** Cool / Balanced / Performance. It uses the same setting as the
  GNOME power menu, so changes made in either place stay in step.
- **Keeps the firmware in step:** GNOME's "Power Saver" mode never moves the HP
  firmware to "cool". The `omen-lite` service does that, and it re-applies the
  settings after suspend or reboot.
- **Fans:** automatic (firmware curve) or max speed. Custom fan curves aren't
  possible on this board through the firmware interface.
- **Status:** fan RPM, CPU and GPU temperature (never wakes a sleeping GPU), power draw on battery.
- **Battery tab:** charge, health (full vs design capacity), charge cycles, power draw,
  time left / to full, voltage.

## Install / remove
    sudo ./install.sh
    sudo ./uninstall.sh

## Use
    omen-lite                     # window
    omen-lite status
    omen-lite mode cool|balanced|performance
    omen-lite fan auto|max
    journalctl -u omen-lite -f    # service log
