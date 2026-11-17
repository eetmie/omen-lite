# OMEN Lite

> [!WARNING]
> I do **NOT** recommend raw-dogging these scripts as-is. They're heavily vibe-coded.
> They work for me, and the machine is in active use, but YMMV.
>
> I take no responsibility for your borked machine.
> Rather, use these scripts as a baseline and do your own thing.

---


Unlocks the full **75 W** GPU power budget on the HP OMEN Transcend 14-fb1xxx (board **8E41**,
RTX 5070 Laptop) under Ubuntu. On Linux the stock `hp-wmi` driver gets 60 W in Balanced and only
65 W in Performance.

It also adds a small `omen-lite fan auto|max` command.

| Power mode (GNOME menu) | GPU limit, stock | GPU limit, OMEN Lite |
|---|---:|---:|
| Power Saver | 60 W (falls back to Balanced, see below) | 10 W (measured on battery) |
| Balanced | 60 W | 60 W |
| Performance | 65 W | **75 W** |

75 W is the maximum the GPU itself reports (`nvidia-smi -q -d POWER`, "Max Power Limit").
Nothing here asks for more than that, and no BIOS or vBIOS is flashed.

## Requirements

- HP OMEN Transcend 14, board `8E41` (`cat /sys/class/dmi/id/board_name`). The installer refuses other boards.
- Ubuntu with a **7.0.x** kernel (tested on 26.04, `7.0.0-43-generic`, BIOS F.05).
- NVIDIA's **open** driver (`nvidia-driver-*-open`). RTX 50 cards don't work with the closed driver.
  Note: Ubuntu 26.04's TPM-backed disk encryption uses a snap kernel that ships only the closed
  driver. Use passphrase (LUKS) encryption or none.

## Install

    git clone <this repo> && cd omen-lite
    sudo ./install.sh

This installs `dkms` if needed, builds the patched `hp-wmi` driver and enables it through
`/etc/modprobe.d/omen-8e41-gpu.conf`. With Secure Boot on, the first install asks you for a one-time
password. At the next boot a blue "MOK management" screen appears: choose **Enroll MOK**, enter that
password, and reboot.

Check it after the reboot:

    cat /sys/devices/platform/hp-wmi/omen_gpu_power   # in Performance: ctgp=1 ppab=1 ...
    nvidia-smi --query-gpu=power.draw,enforced.power.limit --format=csv -l 2

Remove: `sudo ./uninstall.sh`, then reboot. You're back on the stock driver.

**Kernel updates:** DKMS rebuilds the driver automatically for every 7.0.x kernel. A kernel from a
different series is skipped and boots with the stock driver (back to 60/65 W) until the patch is
ported to it.

## Fans

    sudo omen-lite fan max    # full speed, about 6500 RPM
    sudo omen-lite fan auto   # firmware fan curve (the fans really are off when cool)

Max is not kept across a reboot or suspend; it returns to auto. Custom fan curves aren't
possible on this board through the firmware interface.

## Getting the full 75 W: lower the CPU clock

The CPU and GPU share one power budget, and NVIDIA Dynamic Boost (`nvidia-powerd`) moves it between
them. A CPU-heavy game takes watts from the GPU, so 75 W is only reached when the CPU is held back.
Measured in Performance mode with a game at 99 % GPU load (Kingdom Come: Deliverance II):

| CPU max clock | CPU power | GPU power | GPU clock |
|---:|---:|---:|---:|
| 5.4 GHz (no cap) | 44.7 W | 46.3 W | 1656 MHz |
| 4.0 GHz | 42.1 W | 47.5 W | 1704 MHz |
| 3.2 GHz | 29.6 W | 59.4 W | 1999 MHz |
| 2.4 GHz | 24.0 W | 65.2 W | 2105 MHz |

With a GPU-only load (CPU idle) the GPU holds 74.8 W. A cap around 3.2 GHz is a good gaming setting.
It also keeps the CPU near 80 °C instead of 95 °C. To try it (lasts until reboot):

    echo 3200000 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq   # 3.2 GHz
    cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq   # undo

## How it works

`hp-wmi/8e41-gpu-backport.patch` is the full change against Ubuntu's
[`hp-wmi.c` for 7.0.0-43](https://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/resolute/plain/drivers/platform/x86/hp/hp-wmi.c?h=Ubuntu-7.0.0-43.43).
`hp-wmi/hp-wmi.c` is that file with the patch applied. Everything is behind the
`omen_8e41_gpu_boost` module option and only acts on board 8E41.

- The board is in the kernel's generic OMEN list, so the stock driver never sends the GPU power
  commands (WMI 0x22: cTGP, PPAB/Dynamic Boost, D-state) that the newer Victus-S boards get. The patch
  sends them on every profile change, *before* the thermal profile write, because the firmware only
  recalculates its GPU budget on that write and only while PPAB is on:

  | Profile | cTGP | PPAB | GPU budget (50 W base +) |
  |---|---|---|---|
  | Performance | on | on | 10 cTGP + 15 Dynamic Boost = 75 W |
  | Balanced | off | on | 10 Dynamic Boost = 60 W |
  | Cool / low-power | off | off | none = 50 W, then the D-state below |

- It adds a `low-power` profile (the same firmware mode as `cool`). Without it, power-profiles-daemon
  can't map GNOME's Power Saver and falls back to Balanced. In low-power the GPU is also throttled to
  D-state level `omen_8e41_saver_dstate` (default here 5 = 10 W; measured on battery
  1 = 40 W, 2 = 35 W, 3 = 25 W, 4 = 20 W, 5 = 10 W). Change it in `/etc/modprobe.d/omen-8e41-gpu.conf`.
- `/sys/devices/platform/hp-wmi/omen_gpu_power` is a read-only view of the firmware's GPU modes.

The 75 W budget only exists in the firmware's Performance mode, so it isn't available in Balanced.

## Disclaimer

Tested on one laptop. It changes firmware power settings only within the limits HP's own firmware
offers, but you use it at your own risk.

## License

GPL-2.0, the same as the kernel driver it is based on (see `LICENSE`).
