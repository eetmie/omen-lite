# Notes (updated 2026-11-07)

## Laptop
HP OMEN Transcend 14-fb1xxx (board 8E41), Core Ultra 9 285H, RTX 5070 Laptop (Blackwell, 10de:2d18).

## Why we're reinstalling
Ubuntu 26.04 with TPM disk encryption uses a **snap kernel** (`pc-kernel`). Its NVIDIA
add-ons only ship the closed kernel module, and RTX 50 cards need the **open** module
(`RmInitAdapter failed ... requires use of the NVIDIA open kernel modules`).
Canonical (Oct 20, 2026): Blackwell on snap kernels "should be implemented in the next
few months". See canonical/ubuntu-core-docs#417.

Plan: reinstall 26.04 with **LUKS passphrase** encryption (not TPM), normal apt kernel.

## After the reinstall
1. `sudo apt install nvidia-driver-595-open` (or newest `-open`). Secure Boot stays on:
   set a MOK password when asked, enroll it on the blue screen at the next boot.
2. Clone this repo, `sudo ./install.sh`, check `omen-lite status`.
3. Check: `nvidia-smi` works; GPU sleeps at idle
   (`/sys/bus/pci/devices/0000:01:00.0/power/runtime_status` = suspended); idle draw ~6–7 W on battery.
4. Re-test `omen-lite gpu off` / `on` with the working driver, including the refusal
   while an app uses the GPU (couldn't test that on the broken driver).
5. Check GPU temperature shows in the window while the GPU is busy.

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
