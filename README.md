# Synthalia

[![ESPHome](https://img.shields.io/badge/ESPHome-2025.2.2-000000?style=for-the-badge&logo=esphome)](https://esphome.io/)
[![Status](https://img.shields.io/badge/Status-Works_on_my_LED_strip-ff6b6b?style=for-the-badge)](#quick-start)
[![License](https://img.shields.io/badge/License-MIT-00b894?style=for-the-badge)](./LICENSE)

> **A 5m ESP32-S3 light instrument** for people who say  
> _"it's vibe coded"_ and then still tune timing constants like a maniac.

## What This Is

`Synthalia` is an ESPHome-powered LED project with:

- 🖐️ Hand gesture control (VL53L1X ToF)
- 🎛️ Rotary encoder + push button modes
- 🌈 Smooth dim/color control
- ✨ Interactive effects (Candy Cane, Aurora, Matrix, Fire)
- 📡 OTA update workflow

Yes, the project is vibe coded.  
No, it is not random.  
It is **taste-driven + parameter-disciplined chaos**.

Production-grade? No.  
Performance-reviewed with excessive taste? Yes.

---

## Creative Direction

Built under the watchful eye of an **"humble creative director"** (their words, we respect it), with one non-negotiable rule:

**If it feels clunky, it is wrong.**

---

## Quick Start

```bash
python3 -m esphome config s3-synthalia.yaml
python3 -m esphome run s3-synthalia.yaml --device <DEVICE_IP_OR_HOSTNAME>
python3 -m esphome logs s3-synthalia.yaml --device <DEVICE_IP_OR_HOSTNAME>
```

Example:

```bash
python3 -m esphome run s3-synthalia.yaml --device 192.168.178.151
```

---

## Control Model

- `Single click`: cycle `DIM -> COLOR -> DIM`
- `Double click`: enter `EFFECTS` mode
- `Single click` from effects: exit to `DIM`
- `Encoder`: adjust brightness / hue / effect selection (by mode)
- `Hand`: gesture mapping by active mode

---

## Effects (Current)

1. 🍬 Interactive Candy Cane
2. 🌌 Interactive Aurora
3. 🧬 Interactive Matrix
4. 🔥 Interactive Fire (smooth, hand-aware)

Roadmap target: **10 effects** total.

---

## Security Notes

- `secrets.yaml` is local and git-ignored on purpose.
- If a secret ever lands in git: rotate it, then clean history if needed.
- OTA and logs should stay reproducible (`python3 -m esphome ...` commands above).

---

## License

MIT.  
Use it, copy it, modify it, sell it, fork it into oblivion.
Just keep the copyright/license notice.
No warranty, no liability.
