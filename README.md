# Synthalia

[![ESPHome](https://img.shields.io/badge/ESPHome-2025.2.2+-000000?style=for-the-badge&logo=esphome)](https://esphome.io/)
[![ESP32-S3](https://img.shields.io/badge/ESP32--S3-DevKitC--1-4B0082?style=for-the-badge&logo=espressif)](https://www.espressif.com/)
[![LEDs](https://img.shields.io/badge/WS2812B-300_LEDs-ff6b6b?style=for-the-badge)](#hardware)
[![License](https://img.shields.io/badge/License-MIT-00b894?style=for-the-badge)](./LICENSE)

> **300 individually addressable LEDs, a Time-of-Flight sensor, and a rotary encoder walk into a YAML file.**
> Nobody leaves until every smoothing constant has been hand-tuned at 2 AM.

<div align="center">
<img src="assets/synthalia-concept.png" alt="Synthalia concept render — helical LED coil inside frosted glass cloche on concrete base" width="720" />
<br />
<sub>Concept render. Final version: taller, 18 turns, and the gesture sensor is angled at 45° because pointing straight up is for amateurs.</sub>
</div>

<br />

Synthalia is an interactive light instrument disguised as a lamp. Five meters of WS2812B strip wound into an 18-turn helix, sealed inside a frosted glass cloche, controlled by hand gestures and brass knobs, powered by an ESP32-S3 running ESPHome.

It is not a smart lamp. Smart lamps have apps.
This has *physics simulations and a gesture smoothing pipeline.*

---

## Table of Contents

- [The Pitch](#the-pitch)
- [Hardware](#hardware)
- [How It Works](#how-it-works)
- [Effects](#effects)
- [Quick Start](#quick-start)
- [Control Reference](#control-reference)
- [The Smoothing Pipeline](#the-smoothing-pipeline)
- [Pin Reference](#pin-reference)
- [Security](#security)
- [Roadmap](#roadmap)
- [License](#license)

---

## The Pitch

Every LED project starts the same way: *"I'll just make it glow."*

Then you add a rotary encoder because buttons are for people who buy lamps at IKEA. Then a Time-of-Flight sensor because why *tap* a button when you can wave at your furniture like a Jedi with boundary issues. Then you spend a weekend deciding if `alpha = 0.16` or `alpha = 0.18` makes the gesture feel more "buttery" and less "drunk".

That's Synthalia. It's what happens when you give a perfectionist an ESP32, a soldering iron, and no deadline.

**Is it vibe coded?** Yes.
**Is it random?** Absolutely not.
It is **taste-driven, parameter-disciplined chaos** -- every constant hand-tuned for feel, not computed by algorithm. Production-grade aesthetics. Prototype-grade warranty.

---

## Hardware

| Component | Spec | Role |
|---|---|---|
| **MCU** | ESP32-S3 DevKitC-1 | The brain. PSRAM in octal mode because 300 LEDs need room to think. |
| **LED Strip** | WS2812B, 5m, 60/m (300 total) | The soul. Wound into an 18-turn helix inside a frosted glass cloche. |
| **ToF Sensor** | VL53L1X (I2C, 0x29) | The hands-free interface. Reads 10-70 cm at 33 Hz. |
| **Encoder** | KY-040 rotary + push button | The tactile interface. Brass knob. Satisfying clicks. |
| **Enclosure** | Concrete base, frosted glass dome | The reason people ask "wait, you *made* that?" |

The physical design: a helical LED coil inside a glass bell jar, sitting on a sculpted concrete base with brass rotary knobs and a ToF sensor angled at 45 degrees for natural hand interaction. It looks like something from a design museum, or Wes Anderson toilet, you decide. It runs ESPHome.

---

## How It Works

Synthalia has three operating modes, cycled by clicking the encoder button:

```
                    single click              single click
              ┌──── DIM MODE ◄──── COLOR MODE ────┐
              │     (default)       (hue select)   │
              │                                    │
              │         ▲ single click             │
              │         │ (exit effects)           │
              │         │                          │
              │    EFFECTS MODE ◄──────────────────┘
              │    (double-click to enter)
              │
              └─── In every mode:
                   • Encoder adjusts the mode's parameter
                   • Hand gesture maps position to value
                   • 62.5 FPS render loop (16ms interval)
```

**DIM** controls brightness. **COLOR** controls hue. **EFFECTS** activates the fun stuff. In each mode, the rotary encoder provides discrete adjustments while the gesture sensor provides continuous, fluid control. They coexist -- use whichever feels right in the moment.

---

## Effects

Four hand-interactive effects, each running its own physics simulation inside an `addressable_lambda`. Every one responds to the ToF sensor in real time.

### 0. Interactive Candy Cane

Smooth red-to-white striped wave. Uses a `smoothstep` blending curve (`3t^2 - 2t^3`) over a 52-LED period because hard stripes look like a barber pole had an argument with a gear. Hand controls phase position; idle mode auto-scrolls at 0.09 units/frame for that "velvety" drift nobody asked for but everyone notices.

### 1. Interactive Aurora

Multi-layered sine wave interference creating a northern lights gradient. Two wave functions with different frequencies and phase velocities interfere to produce blue-cyan-green-magenta color shifts. Hand controls the wave center point. It's basically `sin(stuff) + sin(other stuff)` mapped to a color ramp, but don't let the math fool you -- it took longer to tune the color breakpoints than to write the wave equations.

### 2. Interactive Matrix DNA

Six independent drops with velocity, direction, and trail rendering. The hand projects a visible "wall" on the strip (Gaussian falloff, +/-10 LEDs). Drops detect the wall, decelerate on approach (45% max slowdown), and reverse on collision with a cyan impact flash. Green trails descend, cyan trails ascend. It's a particle system. In YAML. We don't talk about the line count.

### 3. Interactive Fire

Heat-diffusion fire simulation with hand-aware flame height control. Each frame: cool the heat map, diffuse upward `(h[k] + 2*h[k-1] + h[k-2]) * 0.25`, spark at the base (7.5% chance, 1-2 sparks), temporally smooth everything (`alpha = 0.22`), then map heat to a three-stage color ramp (dark red -> orange -> yellow -> pale). Hand position controls flame height with a secondary dimming channel. Runs at 30ms intervals because fire doesn't need to be *that* fast. Idle mode gently oscillates flame height between 32-62% for a living, breathing quality.

> **Design philosophy:** if the effect doesn't respond to your hand in a way that makes you go *"oh, cool"* within two seconds, the parameters are wrong.

---

## Quick Start

**Prerequisites:** Python 3, ESPHome 2025.2.2+, a `secrets.yaml` file (see [Security](#security)).

```bash
# Validate the config (always do this first)
python3 -m esphome config s3-synthalia.yaml

# Build and flash over the air
python3 -m esphome run s3-synthalia.yaml --device <DEVICE_IP>

# Watch the logs (gesture data, mode changes, effect activations)
python3 -m esphome logs s3-synthalia.yaml --device <DEVICE_IP>
```

> **Note:** `esphome` might not be in your PATH. The `python3 -m esphome` invocation always works. After renaming the node, the first OTA flash may require a direct IP address instead of hostname. This is normal. It's fine. Deep breaths.

---

## Control Reference

| Input | DIM Mode | COLOR Mode | EFFECTS Mode |
|---|---|---|---|
| **Encoder CW** | Brightness +6 | Hue +6 deg | Next effect |
| **Encoder CCW** | Brightness -6 | Hue -6 deg | Previous effect |
| **Single click** | -> COLOR | -> DIM | -> DIM (exit) |
| **Double click** | -> EFFECTS | -> EFFECTS | -- |
| **Hand (10-70cm)** | Maps to brightness | Maps to hue | Controls effect parameter |
| **Hand removed** | Holds last value | Holds last value | Effect goes idle |

The gesture sensor has a 78cm release threshold -- pull your hand beyond that and it gracefully lets go, preserving whatever value you set. Like a good UI, it remembers your intent.

---

## The Smoothing Pipeline

This section exists because someone will look at the gesture code and wonder why it's 40 lines instead of 3.

When the ToF sensor reports a new distance:

1. **Hardware filter** -- sliding window average (window=3) at the sensor level.
2. **Dead zone** -- deltas smaller than 0.3% are discarded (anti-tremor).
3. **Adaptive alpha** -- small movements: `alpha = 0.16` (smooth). Large movements: `alpha = 0.22` (responsive).
4. **Max step limiter** -- no single update moves more than 1.8% of the range. Prevents the "my hand twitched and the brightness went to the sun" problem.
5. **Per-effect smoothing** -- each effect applies its own position smoothing on top (0.03-0.30 depending on the effect's personality).

The result: gestures feel fluid and intentional, never jittery, never laggy. Achieving this took longer than writing the effects themselves. Worth it.

---

## Pin Reference

```
ESP32-S3 DevKitC-1
├── GPIO4  (SDA) ──── VL53L1X ToF sensor
├── GPIO5  (SCL) ──── VL53L1X ToF sensor     I2C @ 400kHz
├── GPIO13 (DATA) ─── WS2812B strip (300 LEDs, RMT ch.1)
├── GPIO48 (DATA) ─── Onboard RGB LED (1 LED, RMT ch.0)
├── GPIO12 (A) ────── Rotary encoder pin A    INPUT_PULLUP
├── GPIO11 (B) ────── Rotary encoder pin B    INPUT_PULLUP
└── GPIO10 (BTN) ──── Encoder push button     INPUT_PULLUP, inverted
```

---

## Security

`secrets.yaml` stores WiFi credentials, API encryption keys, and OTA passwords. It is local-only and git-ignored. This is by design, not by accident.

- **Never** commit `secrets.yaml`. The `.gitignore` has your back, but paranoia is a feature.
- If a secret ever lands in git history: rotate it immediately, then clean history.
- API communication uses encryption. OTA uses ESPHome's built-in platform auth.

---

## Roadmap

Currently **4 of 10** planned effects. The six remaining slots are reserved for whatever obsessive parameter-tuning marathon happens next.

The hardware design is converging on the final form: 18-turn helix, frosted glass cloche, concrete base, brass knobs, ToF sensor at 45 degrees for natural hand-over interaction. Software follows the hardware -- new effects will be designed for the helical geometry, not a flat strip.

---

## License

[MIT](./LICENSE). Use it, fork it, modify it, learn from it, ship it, put it on a lamp you sell at a craft fair.
Just keep the copyright notice. No warranty. No liability. No hard feelings.

---

<div align="center">

*Built with ESPHome, too many smoothing constants, and the unwavering belief*
*that `alpha = 0.16` is objectively better than `alpha = 0.15`.*

</div>
