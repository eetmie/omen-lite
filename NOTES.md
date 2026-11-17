# Notes (updated 2026-11-07)

## Laptop
HP OMEN Transcend 14-fb1xxx (board 8E41), Core Ultra 9 285H, RTX 5070 Laptop (Blackwell, 10de:2d18).

## Why we reinstalled
Ubuntu 26.04 with TPM disk encryption uses a **snap kernel** (`pc-kernel`). Its NVIDIA
add-ons only ship the closed kernel module, and RTX 50 cards need the **open** module
(`RmInitAdapter failed ... requires use of the NVIDIA open kernel modules`).
Canonical (Oct 20, 2026): Blackwell on snap kernels "should be implemented in the next
few months". See canonical/ubuntu-core-docs#417.

Fix: reinstalled 26.04 with **LUKS passphrase** encryption (not TPM), normal apt kernel.

## Reinstall results (2026-11-07)
Kernel 7.0.0-43-generic (apt), `nvidia-driver-615-open` 615.71.09 + 
`linux-modules-nvidia-615-open-generic-hwe-26.04`. Secure Boot on, MOK enrolled, module loads.

1. [x] Driver installed (went with 615-open, not 595). Old 595 modules package is left in
   `rc` state; harmless, purge with `sudo apt purge linux-modules-nvidia-595-open-7.0.0-43-generic`.
2. [x] `install.sh` run; installed files match the repo; `omen-lite.service` running and
   syncing firmware profile (cool/balanced) with the power mode.
3. [x] `nvidia-smi` works (RTX 5070 Laptop, CUDA 13.4). GPU reaches `suspended` at idle
   (runtime D3 fine-grained). Idle draw on battery 5.9–6.4 W. Note: running `nvidia-smi`
   wakes the GPU for a few seconds (~12 W), so wait before measuring.
4. [x] GPU off/on toggle removed (2026-11-10): every GTK app holds /dev/nvidia, so it
   never worked in a session and its retry loop cost CPU.
5. [x] GPU temperature shows in `omen-lite status` (52 °C, driver 615.71.09). Still worth
   a look in the window while the GPU is busy.

Also set black wallpaper/lock screen and a black Ptyxis palette
(`~/.local/share/org.gnome.Ptyxis/palettes/Ubuntu Black.palette`) to save power on the OLED.

## Measurements (snap-kernel install, 16-thread busy loop, 60 s)
Idle on battery: 6.6 W (dGPU in D3cold).

| Mode | Battery | AC, original PSU (CPU package) |
|---|---|---|
| Cool | 34 W, 2.00 GHz, 66 °C | 28 W, 2.01 GHz, 61 °C |
| Balanced | 36 W, 2.01 GHz, 72 °C | 28 W, 2.02 GHz, 68 °C |
| Performance | 50 W, 2.67 GHz, 80 °C | 71 W, 3.46 GHz, 102 °C |

- A 65 W USB-C charger throttles every mode to ~20 W / 1.56 GHz.
- Fans read 0 RPM in auto because they really are off when cool; max = ~6500 RPM.
- RAPL power limits read 65 / 80 W in every mode; the real per-mode limits are set by
  the firmware and can't be read, so the app doesn't show them.

## TODO
- Warn when an under-spec charger is throttling the CPU (needs testing with both chargers).
